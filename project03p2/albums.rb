require 'sinatra'
require 'data_mapper'
require_relative 'album'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/albums.sqlite3.db")

set :port, 8080

post "/list" do
	@order = params[:order]
	@albums = Album.all(:order => @order.intern.asc)
	@rank_to_highlight = params[:rank].to_i

	erb :list
end

get "/form" do
	erb :form
end