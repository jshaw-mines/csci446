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
    File.open("form_top.html", "rb") { |form| response.write(form.read) }
    (1..100).each { |i| response.write("<option value=\"#{i}\">#{i}</option>\n") }
    File.open("form_bottom.html", "rb") { |form| response.write(form.read) }
    response.finish
  end

  def render_list(request)
    response = Rack::Response.new

    sort_order = request.params['order']
    rank_to_highlight = request.params['rank'].to_i

    File.open("list_top.html", "rb") { |template| response.write(template.read) }
    response.write("<p>Sorted by #{sort_order.capitalize}</p>\n")

	raw_albums = get_albums(sort_order)
	albums = raw_albums.each { |album| Album.new(album.join ",") }

    response.write("<table>\n")
    write_album_table_rows(albums, response, rank_to_highlight)

    File.open("list_bottom.html", "rb") { |template| response.write(template.read) }
    response.finish
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end

  def write_album_table_rows(albums, response, rank_to_highlight)
    albums.each do |album|
      response.write(row_tag_for(album, rank_to_highlight))
      response.write("\t\t<td>#{album.rank}</td>\n")
      response.write("\t\t<td>#{album.title}</td>\n")
      response.write("\t\t<td>#{album.year}</td>\n")
      response.write("\t</tr>\n")
    end
  end
  
  def get_albums(order)
  
	begin
		db = SQLite3::Database.open("albums.sqlite3.db")
		
		stm = db.prepare "SELECT * FROM albums ORDER BY #{order}"
		res = stm.execute
		
	rescue SQLite3::Exception => e
		puts "Exception"
		puts e
		
	ensure
		stm.close if stm
		db.close if db
	end
	
	return res
  end

  def row_tag_for(album, rank_to_highlight)
    album.rank == rank_to_highlight ? "\t<tr class=\"highlighted\">\n" : "\t<tr>\n"
  end

end

Signal.trap('INT') { Rack::Handler::WEBrick.shutdown } # Ctrl-C to quit
Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080