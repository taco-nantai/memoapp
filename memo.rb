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

def read_csv
  CSV.read(MEMOS_CSV)
end

def write_csv(memo)
  CSV.open(MEMOS_CSV, 'a') { |memos| memos << memo }
end

def get_memo(id)
  memo_values = []
  CSV.foreach(MEMOS_CSV) do |memo|
    memo_values = memo if memo[0] == id
  end
  memo_values
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
  @memos = read_csv
  erb :index
end

get '/memo/*' do |id|
  @memo = {}
  @memo[:id], @memo[:title], @memo[:text] = get_memo(id)
  erb @memo[:id] ? :memo : :notFound
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
  memo = { id: SecureRandom.uuid, title: params[:title], text: params[:text]}
  p '*************************************************************************************************'
  p memo[:id]
  p '*************************************************************************************************'
  write_csv([memo[:id], memo[:title], memo[:text]])
  redirect "/memo/#{memo[:id]}"
end

patch '/memo/*' do |id|
  p '*************************************************************************************************'
  p id
  p '*************************************************************************************************'
  edited_memos = read_csv
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
  edited_memos = read_csv.reject { |memo| memo[0] == id }
  replace_memos(edited_memos)
  redirect '/'
end

not_found do
  status 404
  erb :notFound
end
