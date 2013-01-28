require 'rack'
 
class AlbumApp
	def call(env)
		request = Rack::Request.new(env)
		case request.path
		when "/form" then render_form(request)
		when "/list" then render_list(request)
		when "/list.css" then render_css(request)
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
		
		get = request.GET()
		order = get["order"]
		rank = get["rank"].to_i
		
		data = []
		m=0
		f.each do |line|	
			val = line.split(", ")
			data[m] = [val[0], val[1].chomp]
			m+=1
		end
		
		case order
			when "rank" then #dont sort
			when "name" then data.sort! {|a, b| a[0] <=> b[0]}
			when "year" then data.sort! {|a, b| a[1] <=> b[1]}
		end
		
		n=1
		data.each do |cell|	
			name = cell[0]
			year = cell[1]
			if rank == n
				response.write("<tr id=\"highlight\">")
			else
				response.write("<tr>")
			end
			response.write("<td>#{n}</td><td>#{name}</td><td>#{year}</td></tr>")
			n+=1
		end
		
		response.write("</table></body></html>")
		response.finish
	end

	def render_css (request)
		response = Rack::Response.new
		response.write(File.open("list.css").read)
		response.finish
	end
	
	def render_404
		[404, {"Contenet-Type" => "text/plain"}, ["GO AWAY... newb"]]
	end
	
end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080