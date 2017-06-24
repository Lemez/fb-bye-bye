#!/usr/bin/env ruby

require 'koala'
require 'active_support'
require 'active_support/core_ext'
require 'json'

Dir.glob("lib/*.rb").each{|f| require_relative(f)}

def update_html

		@oauth = Koala::Facebook::OAuth.new
		token = @oauth.get_app_access_token
		@graph = Koala::Facebook::API.new(token)

	ARTISTS.each do |artist|

		p "Updating page - #{artist['name']}"

		responses = @graph.get_connection("#{artist['page_id']}", 'feed', {
	  		limit: '50',
	  		fields: ['message', 'actions', 'child_attachments', 'id', 'from', 'type', 'picture', 'link', 'created_time', 'updated_time']
	})

		shares = responses.reject{|m| m['picture'].nil? && m['link'].nil? }
		save_file_as(shares.to_json, "json/#{artist['file']}")
	
	end

	all_data = render_page
	save_file_as(all_data, 'index.html')
	
end

def render_page

	@opening = %Q(
				<!DOCTYPE html>
				<html>
					<head>
						<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
						<title>Carnatic Facebook</title>
						<meta charset="UTF-8">
						<meta name="viewport" content="width=device-width, initial-scale=1">
						<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
						<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Montserrat">
						<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
					</head>
					<style>
						body,h1 {font-family: "Montserrat", sans-serif}
						img {margin-bottom: -7px}
						.w3-row-padding img {margin-bottom: 12px}
					</style>
					<body>

						<!-- !PAGE CONTENT! -->
						<div class="w3-content" style="max-width:1500px">

							<!-- Grid -->
							<div class="w3-row" id="myGrid" style="margin-bottom:128px">
								<div class='w3-third' style='overflow: auto; max-height: 100vh;'>
				  )

		@closing = %Q(
								</div>
							</div>

							<!-- End Page Content -->
						</div>

						<!-- Footer -->
						<footer class="w3-container w3-padding-64 w3-light-grey w3-center w3-opacity w3-xlarge" style="margin-top:128px"> 
					  		<p class="w3-medium">Powered by <a href="https://www.ruby-lang.org/en/" target="_blank" class="w3-hover-text-green">Ruby</a>, <a href="https://github.com/arsduo/koala" target="_blank" class="w3-hover-text-green">Koala</a> and <a href="https://www.w3schools.com/w3css/default.asp" target="_blank" class="w3-hover-text-green">w3.css</a></p>
						</footer>
				 
					</body>
				</html>
			)

	ARTISTS.each do |artist|

		@opening += "<h2 style='min-width:33%;position:fixed;text-align:center;background:white;line-height:2em;'>#{artist['name']}</h2>"
		data = File.readlines("json/#{artist['file']}")

		p "***** #{artist['name']}: #{data.length} items *****"
		
		data.each do |d| 
			obj = JSON.parse(d)
			obj.each do |item|

				date = Date.parse(item['updated_time']).strftime("%A, %d %b %Y")
				extrastyle = (item==obj.first ? 'margin-top:2em;' : '')
				from = "#{item['from']['name']}"
				header = item['type'].titleize
				message = item['message']

				pic = item["picture"]
				photo = "<img src='#{pic}' width='300'/>"
				
				@opening += %Q( 
									<div style='border: 1px solid gray;padding-left:2em;#{extrastyle}'>
										<h3>#{header}</h3>
										<h4>#{from}</h4>
										<h6>#{date}</h6>
										<a href='#{item["link"]}' style='font-decoration:none;'>
											#{photo}
										</a>
											<p style='font-size:1em;'>#{message}</p>
									</div>
							)		
			end
		end 

		unless artist==ARTISTS.last 
			@opening +=%Q(</div><div class='w3-third' style='overflow: auto; max-height: 100vh;'>)
		end
	end

	@opening + @closing

end

def save_file_as(d,target)
	File.open(target, "w") {|file|file.puts(d)}
end




# -----------  unused functions -----------
def send_notifications_if_new(shares)

	shares.each do |link|

		if less_than_x_hours_old?(24,link)

			p ".....";link.each_pair{|k,v| p "*** #{k}: #{v}"};p "....."
			apple_notification(link)
			
		end
	end
end

def apple_notification(link)

		# `osascript -e 'display notification "#{usage}" with title "Prince Rama Varma"'`
		# `osascript -e 'tell application (path to frontmost application as text) to display dialog "#{usage}"'`
	url = link['link']
	# yes = (link['type']=='photo' ? "Photo" : "Video")
	
	`terminal-notifier -message "#{link['message']}" -title "Prince Rama Varma" -open #{url}`
end

def less_than_x_hours_old?(x,link)

	result = false

	linktime = Time.parse(link['updated_time'])

	if linktime > x.hours.ago
		# puts "It is less than #{x} hours after #{linktime}"
		result = true
	else 
		# puts "It is not less than #{x} hours after #{linktime}"
	end

	result
end

def get_detailed_info(link)
	@graph.get_object(link[:id])
end


