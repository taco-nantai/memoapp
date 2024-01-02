#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pg'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'

DB_NAME = 'memoapp'
QUERIES = {
  select_one: 'SELECT * FROM memo WHERE id = $1',
  select_all: 'SELECT * FROM memo ORDER BY created_at',
  insert: 'INSERT INTO memo (id, title, text) VALUES ($1, $2, $3)',
  update: 'UPDATE memo SET title = $1, text = $2 WHERE id = $3',
  delete: 'DELETE FROM memo WHERE id = $1'
}.freeze

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
  conn.exec_params(QUERIES[:select_one], [id]).first
end

def select_all
  conn = connect_db
  conn.exec_params(QUERIES[:select_all])
end

def insert_memo(memo)
  conn = connect_db
  conn.exec_params(QUERIES[:insert], [memo[:id], memo[:title], memo[:text]])
end

def update_memo(memo)
  conn = connect_db
  conn.exec_params(QUERIES[:update], [memo[:title], memo[:text], memo[:id]])
end

def delete_memo(id)
  conn = connect_db
  conn.exec_params(QUERIES[:delete], [id])
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
