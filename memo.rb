#!/usr/bin/env ruby
# frozen_string_literal: true

# myapp.rb

require 'sinatra'
require 'sinatra/reloader'
require 'csv'

MEMOS_CSV = 'memos.csv'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def get_memo(id)
  memo_infomation = []
  CSV.foreach(MEMOS_CSV) do |memo|
    memo_infomation = memo if memo[0] == id
  end
  memo_infomation
end

def maximum_memo_id
  max_memo_id = 0
  CSV.foreach(MEMOS_CSV) do |memo|
    memo_id = memo[0].to_i
    max_memo_id = memo_id if max_memo_id < memo_id
  end
  max_memo_id
end

def replace_memos(edited_memos)
  CSV.open(MEMOS_CSV, 'w') do |memos|
    edited_memos.each do |edited_memo|
      memos << edited_memo
    end
  end
end

get '/' do
  @title = 'メモ一覧'
  @memos = CSV.read(MEMOS_CSV)
  erb :index
end

get '/memo/*' do |id|
  @memo_id, @memo_title, @memo_text = get_memo(id)
  erb @memo_id ? :memo : :notFound
end

get '/addition' do
  @title = '新規作成'
  erb :addition
end

get '/editing/*' do |id|
  @memo = {}
  @memo[:id], @memo[:title], @memo[:text] = get_memo(id)
  erb @memo[:id] ? :editing : :notFound
end

post '/memo' do
  memo_id = maximum_memo_id + 1
  memo_title = params[:title]
  memo_content = params[:text]
  CSV.open(MEMOS_CSV, 'a') { |memos| memos << [memo_id, memo_title, memo_content] }
  redirect "/memo/#{memo_id}"
end

patch '/memo/*' do |id|
  edited_memos = CSV.read(MEMOS_CSV)
  edited_memos.each.with_index do |memo, index|
    if memo[0] == id
      edited_memos[index] = [id, params[:title], params[:text]]
      break
    end
  end
  replace_memos(edited_memos)
  redirect "/memo/#{id}"
end

delete '/memo/*' do |id|
  edited_memos = CSV.read(MEMOS_CSV).reject { |memo| memo[0] == id }
  replace_memos(edited_memos)
  redirect '/'
end

not_found do
  status 404
  erb :notFound
end
