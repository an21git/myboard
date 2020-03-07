require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'
require 'pry'

enable :sessions

def db
  PG::connect(
    :host => ENV['DB_HOST'],
    :user => ENV['DB_USER'],
    :password => ENV['DB_PASSWORD'],
    :dbname => ENV['DB_NAME']
  ) 
end

before do
  unless request.path == '/login' || request.path == '/signup' || session[:id]
    session[:notice] = {key: "danger", message: "ログインして下さい"}
    redirect '/login'
  end
  @admin = db.exec_params("select * from users where id = $1",[session[:id]]).first
  @message = session.delete :notice
end

before '/edit/*' do
  
end

get '/signup' do
  erb :signup
end

post '/signup' do
  name = params[:name]
  email = params[:email]
  password = params[:password]
  birthday = params[:birthday]
  introduce = params[:introduce]
  if birthday.empty?
    user = db.exec_params("insert into users(name, email, password, introduce) values($1, $2, $3, $4) returning id",[name, email, password, introduce]).first
  else
    user = db.exec_params("insert into users(name, email, password, birthday, introduce) values($1, $2, $3, $4, $5) returning id",[name, email, password, birthday, introduce]).first
  end
  session[:id] = user['id']
  session[:notice] = {key: "success", message: "登録が完了しました"}
  redirect '/posts'
end

get '/login' do
  erb :login
end

post '/login' do
  email = params[:email]
  password = params[:password]
  user = db.exec_params("select * from users where email = $1 and password = $2",[email, password]).first
  session[:id] = user['id']
  session[:notice] = {key: "success", message: "ログインしました"}
  redirect '/posts'
end

get '/logout' do
  session.clear
  session[:notice] = {key: "danger", message: "ログアウトしました"}
  redirect '/login'
end

get '/posts' do
  @posts = db.exec_params("select posts.*, users.name, to_char(posts.updated_at, 'yyyy/mm/dd hh24:mm:ss') as updated_at from posts join users on users.id = posts.user_id")
  erb :posts
end

get '/posts/new' do
  erb :post_new
end

post '/create' do
  title = params[:title]
  content = params[:content]
  if params[:image].empty?
    db.exec_params("insert into posts(title, content, user_id) values($1, $2, $3, $4)",[title, content, session[:id]])
  else
    image_name = params[:image][:filename]
    image_data = params[:image][:tempfile]
    FileUtils.mv(image_data, "./public/images/#{image_name}")
    db.exec_params("insert into posts(title, content, image, user_id) values($1, $2, $3, $4)",[title, content, image_name, session[:id]])
  end
  session[:notice] = {key: "primary", message: "新規投稿しました"}
  redirect '/posts'
end

get '/posts/:id' do
  id = params[:id]
  @post = db.exec_params("select posts.*, users.name, to_char(posts.updated_at, 'yyyy/mm/dd hh24:mm:ss') as updated_at from posts join users on users.id = posts.user_id where posts.id = $1", [id]).first
  erb :post
end

get '/posts/:id/edit' do
  id = params[:id]
  @post = db.exec_params("select posts.*, users.name, to_char(posts.updated_at, 'yyyy/mm/dd hh24:mm:ss') as updated_at from posts join users on users.id = posts.user_id where posts.id = $1", [id]).first
  if session[:id] != @post['user_id']
    session[:notice] = {key: "warning", message: "アクセス権限がありません"}
    redirect '/posts' 
  end
  erb :post_edit
end

post '/posts/:id/update' do
  id = params[:id]
  title = params[:title]
  content = params[:content]
  binding.pry
  if params[:image].nil?
    db.exec_params("update posts set title = $1, content = $2 where id = $3", [title, content, id])
  else
    image_name = params[:image][:filename]
    image_data = params[:image][:tempfile]
    FileUtils.mv(image_data, "./public/images/#{image_name}")
    db.exec_params("update posts set title = $1, content = $2, image = $3 where id = $4", [title, content, image_name, id])
  end
  session[:notice] = {key: "success", message: "投稿を更新しました"}
  redirect "posts/#{id}"
end

get '/posts/:id/destroy' do
  id = params[:id]
  @post = db.exec_params("select * from posts where id = $1", [id]).first
  if session[:id] != @post['user_id']
    session[:notice] = {key: "warning", message: "アクセス権限がありません"}
    redirect '/posts' 
  end
  db.exec_params("delete from posts where id = $1", [id])
  session[:notice] = {key: "danger", message: "投稿を削除しました"}
  redirect '/posts'
end

get '/users' do
  @users = db.exec_params("select * from users where not id = $1", [session[:id]])
  erb :users
end

get '/users/:id' do
  redirect 'mypage' if params['id'] == session[:id]
  id = params['id']
  @user = db.exec_params("select *, to_char(created_at, 'yyyy/mm/dd') as created_at from users where id = $1", [id]).first
  erb :user
end

get '/mypage' do
  @user = db.exec_params("select *, to_char(created_at, 'yyyy/mm/dd') as created_at from users where id = $1", [session[:id]]).first
  erb :mypage
end

get '/mypage/:id/edit' do
  
end

post'/mypage/:id/update' do

end

get '/search' do
  @searches = db.exec_params("select * from posts where title like $1 or content like $1", ["%#{params[:search]}%"])
  erb :search
end