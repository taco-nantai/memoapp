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

def select_one(id)
  conn = connect_db
  conn.exec_params('SELECT * FROM memo WHERE id = $1', [id]).first
end

def select_all
  conn = connect_db
  conn.exec_params('SELECT * FROM memo ORDER BY created_at')
end

def insert_memo(memo)
  conn = connect_db
  conn.exec_params('INSERT INTO memo (title, text) VALUES ($1, $2) RETURNING id', [memo[:title], memo[:text]])
end

def update_memo(memo)
  conn = connect_db
  conn.exec_params('UPDATE memo SET title = $1, text = $2 WHERE id = $3', [memo[:title], memo[:text], memo[:id]])
end

def delete_memo(id)
  conn = connect_db
  conn.exec_params('DELETE FROM memo WHERE id = $1', [id])
end

get '/' do
  @title = 'メモ一覧'
  @memos = select_all
  erb :index
end

get '/memo/*' do |id|
  @title = 'メモ'
  @memo = select_one(id)
  erb @memo ? :memo : :notFound
end

get '/addition' do
  @title = '新規作成'
  erb :addition
end

get '/editing/*' do |id|
  @title = '編集'
  @memo = select_one(id)
  erb @memo ? :editing : :notFound
end

post '/memo' do
  returning = insert_memo({ title: params[:title], text: params[:text] })
  redirect "/memo/#{returning.first['id']}"
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
