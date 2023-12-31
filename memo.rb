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
  select: 'SELECT * FROM memo ORDER BY created_at',
  insert: 'INSERT INTO memo (id, title, text) VALUES ($1, $2, $3)',
  update: 'UPDATE memo SET title = $1, text = $2 WHERE id = $3',
  delete: 'DELETE FROM memo WHERE id = $1'
}.freeze

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def manipulate_db(manipulation, memo = nil)
  conn = PG.connect(dbname: DB_NAME)
  query = QUERIES[manipulation]
  case manipulation
  when :select_one then conn.exec_params(query, [memo[:id]]).first
  when :select then conn.exec_params(query)
  when :insert then conn.exec_params(query, [memo[:id], memo[:title], memo[:text]])
  when :update then conn.exec_params(query, [memo[:title], memo[:text], memo[:id]])
  when :delete then conn.exec_params(query, [memo[:id]])
  end
end

get '/' do
  @title = 'メモ一覧'
  @memos = manipulate_db(:select)
  erb :index
end

get '/memo/*' do |id|
  @title = 'メモ'
  @memo = manipulate_db(:select_one, { id: })
  erb @memo ? :memo : :notFound
end

get '/addition' do
  @title = '新規作成'
  erb :addition
end

get '/editing/*' do |id|
  @title = '編集'
  @memo = manipulate_db(:select_one, { id: })
  erb @memo ? :editing : :notFound
end

post '/memo' do
  id = SecureRandom.uuid
  manipulate_db(:insert, { id:, title: params[:title], text: params[:text] })
  redirect "/memo/#{id}"
end

patch '/memo/*' do |id|
  manipulate_db(:update, { id:, title: params[:title], text: params[:text] })
  redirect "/memo/#{id}"
end

delete '/memo/*' do |id|
  manipulate_db(:delete, { id: })
  redirect '/'
end

not_found do
  status 404
  erb :notFound
end
