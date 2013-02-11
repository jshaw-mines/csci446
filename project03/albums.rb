#!/usr/bin/env ruby
require 'rack'
require 'sqlite3'
require_relative 'album'

class AlbumApp
  def call(env)
    request = Rack::Request.new(env)
    case request.path
    when "/form" then render_form(request)
    when "/list" then render_list(request)
    else render_404
    end
  end

  def render_form(request)
    response = Rack::Response.new
	erb = ERB.new(File.read("form.html.erb")).result(binding)
	response.write(erb)
    response.finish
  end

  def render_list(request)
    response = Rack::Response.new

    sort_order = request.params['order']
    rank_to_highlight = request.params['rank'].to_i
	
	albums = get_albums(sort_order)
	
	erb = ERB.new(File.read("list.html.erb")).result(binding)
	response.write(erb)
	
    response.finish
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end
  
  def get_albums(order)
  
	begin
		db = SQLite3::Database.open("albums.sqlite3.db")
		
		stm = db.prepare "SELECT * FROM albums ORDER BY #{order}"
		raw_albums = stm.execute
		
		albums = raw_albums.map { |album| Album.new(album.join ",") }
		
	rescue SQLite3::Exception => e
		puts "Exception"
		puts e
		
	ensure
		stm.close if stm
		db.close if db
	end
	
	return albums
	
  end

end

Signal.trap('INT') { Rack::Handler::WEBrick.shutdown } # Ctrl-C to quit
Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080