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
		f = File.open("top_100_albums.txt")
		response.write(File.open("list.html").read)
		
		n=1
		f.each do |line|
			response.write("<tr><td>#{n}</td>")
			line.split(", ").each do |cell|
				response.write("<td>#{cell}</td>")
			end
			response.write("</tr>")
			x+=1
		end
		response.write("</table></body></html>")
		response.finish
	end

	def render_404
		[404, {"Contenet-Type" => "text/plain"}, ["GO AWAY... newb"]]
	end
	
end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080