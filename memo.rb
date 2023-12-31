#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pg'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'

DB_NAME = 'memoapp'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def connect_db
  PG.connect(dbname: DB_NAME)
end

def get_memo(id)
  connect = connect_db
  result = connect.exec("SELECT * FROM memo WHERE id = '#{id}'")
  result.first
end

def read_memos
  connect = connect_db
  connect.exec('SELECT * FROM memo')
end

def insert_memo(memo)
  connect = connect_db
  connect.exec("INSERT INTO memo VALUES ('#{memo[:id]}', '#{memo[:title]}', '#{memo[:text]}')")
end

def update_memo(memo)
  connect = connect_db
  connect.exec("UPDATE memo SET title = '#{memo[:title]}', text = '#{memo[:text]}' WHERE id = '#{memo[:id]}'")
end

def delete_memo(id)
  connect = connect_db
  connect.exec("DELETE FROM memo WHERE id = '#{id}'")
end

get '/' do
  @title = 'メモ一覧'
  @memos = read_memos
  erb :index
end

get '/memo/*' do |id|
  @title = 'メモ'
  @memo = get_memo(id)
  erb @memo ? :memo : :notFound
end

get '/addition' do
  @title = '新規作成'
  erb :addition
end

get '/editing/*' do |id|
  @title = '編集'
  @memo = get_memo(id)
  erb @memo ? :editing : :notFound
end

post '/memo' do
  id = SecureRandom.uuid
  insert_memo({ id:, title: params[:title], text: params[:text] })
  redirect "/memo/#{id}"
end

patch '/memo/*' do |id|
  update_memo({ id:, title: params[:title], text: params[:text] })
  redirect "/memo/#{id}"
end

delete '/memo/*' do |id|
  delete_memo(id)
  redirect '/'
end

not_found do
  status 404
  erb :notFound
end
