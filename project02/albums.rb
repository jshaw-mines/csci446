require 'rack'
 
class AlbumApp
	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/form" then render_form(request)
		when "/list" then render_list(request)
		else render_404
		end
	end

	def render_form (request)
		response = Rack::Response.new
		File.open("form.html", "rb") do	|f|
			response.write(f.read)
			100.times do |n|
				response.write("<option value=#{n+1}>#{n+1}</option> ")
			end
			response.write ("</select><input type=\"submit\" value=\"Display List\"/></form></body></html>")
		end
		response.finish
	end

	def render_list (request)
		response = Rack::Response.new
		File.open("top_100_albums")
		response.finish
	end

	def render_404
		[404, {"Contenet-Type" => "text/plain"}, ["GO AWAY... newb"]]
	end
	
end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080