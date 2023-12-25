#!/usr/bin/env ruby
# frozen_string_literal: true

# myapp.rb

require 'csv'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'

MEMOS_CSV = 'memos.csv'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def get_memo(id)
  read_memos.each { |memo| return memo if memo['id'] == id }
  nil
end

def read_memos
  CSV.read(MEMOS_CSV, headers: true)
end

def add_memo(memo)
  CSV.open(MEMOS_CSV, 'a') { |memos| memos << [memo['id'], memo['title'], memo['text']] }
end

def write_memos(edited_memos)
  CSV.open(MEMOS_CSV, 'w') do |memos|
    memos << %w[id title text]
    edited_memos.each { |edited_memo| memos << [edited_memo['id'], edited_memo['title'], edited_memo['text']] }
  end
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
  memo = { 'id' => SecureRandom.uuid, 'title' => params[:title], 'text' => params[:text] }
  add_memo(memo)
  redirect "/memo/#{memo['id']}"
end

patch '/memo/*' do |id|
  edited_memos = read_memos.map { |memo| memo['id'] == id ? { 'id' => id, 'title' => params[:title], 'text' => params[:text] } : memo }
  write_memos(edited_memos)
  redirect "/memo/#{id}"
end

delete '/memo/*' do |id|
  edited_memos = read_memos.reject { |memo| memo['id'] == id }
  write_memos(edited_memos)
  redirect '/'
end

not_found do
  status 404
  erb :notFound
end
