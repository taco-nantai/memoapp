#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'

HEADERS = %w[
  id
  title
  text
].freeze

MEMOS_CSV = 'memos.csv'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def get_memo(id)
  read_memos.find { |memo| memo['id'] == id }
end

def read_memos
  CSV.read(MEMOS_CSV, headers: true)
end

def write_memos(edited_memos)
  CSV.open(MEMOS_CSV, 'w', headers: HEADERS, write_headers: true) do |memos|
    edited_memos.each { |edited_memo| memos << edited_memo.to_hash }
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
  id = SecureRandom.uuid
  row = CSV::Row.new([], [])
  row << { 'id' => id }
  row << { 'title' => params[:title] }
  row << { 'text' => params[:text] }
  edited_memos = read_memos
  edited_memos << row
  write_memos(edited_memos)
  redirect "/memo/#{id}"
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
