#!/usr/bin/env ruby

require 'koala'
require 'active_support'
require 'active_support/core_ext'
require 'json'
require 'uri'
require 'fastimage'

Dir.glob("lib/*.rb").each{|f| require_relative(f)}

$icons={:photo=>'assets/noun_778937_cc.svg',:video=>'assets/noun_1018049_cc.svg',:link=>'assets/noun_1038899_cc.svg'}

def initializeFBApi
	@oauth = Koala::Facebook::OAuth.new
	token = @oauth.get_app_access_token
	@graph = Koala::Facebook::API.new(token)
end

def test
	initializeFBApi
	get_data(ARTISTS,false)
	read_updates_json
end

def update_html

		initializeFBApi

		get_data(ARTISTS,true)

		save_last

		all_data = render_page
		
end

def load_last
	last = {}
	data = JSON.parse(File.readlines("json/last.json")[0])
	data.each{|e| last[e.keys.first]=e.values.first}
	last	
end

def save_last

	results = []
	ARTISTS.each do |artist|
		data = JSON.parse(File.readlines("json/#{artist['file']}")[0])
		results << {artist['name']=>data.first['id']}
	end

	save_file_as(results.to_json, 'json/last.json')

end

def how_many_new_stories?(newdata,name)

	last_data = load_last
	last_id_for_artist = last_data[name]

	ids = newdata.collect{|d|d['id']}
	index = ids.index(last_id_for_artist)

	index

end

def get_data(object,saving)

	updates = []
	case object
	when ARTISTS
		object.each do |artist|

			p "Updating page - #{artist['name']}"

			responses = @graph.get_connection("#{artist['page_id']}", 'feed', {
	  			limit: '50',
	  			fields: ['message', 'actions', 'child_attachments', 'id', 'from', 'type', 'picture', 'link', 'created_time', 'updated_time']
			})

			shares = responses.reject{|m| m['picture'].nil? && m['link'].nil? }

			newstories = how_many_new_stories?(shares,artist['name'])
			updates << {artist['name']=>newstories}

			save_file_as(shares.to_json, "json/#{artist['file']}") if saving

		end

		save_file_as(updates.to_json, "json/updates.json")

	when FRIENDS
		responses = []
		users = FRIENDS['people'].collect{|o|o['page_id']}.map(&:to_i)
		p users

		@graph.batch do |batch_api|

			users.each do |user|
				p batch_api.get_connections(user,'permissions')
				responses << batch_api.get_connections(user, 'posts', {
	  				limit: '20',
	  				fields: ['message', 'actions', 'child_attachments', 'id', 'from', 'type', 'picture', 'link', 'created_time', 'updated_time']
				})
			end
		end

		shares = responses.flatten.sort{|x,y| Time.parse(y['updated_time']) <=> Time.parse(x['updated_time'])}
		save_file_as(shares.to_json, "json/#{FRIENDS['file']}") if saving
	end
end

def resolve_image(item)
	pic = item["picture"]

	if pic.nil?

		pic = "https://qph.ec.quoracdn.net/main-qimg-1678635ef8d482d92921313df9227a35-c"
	
	elsif URI.unescape(pic).include?("ytimg") || URI.unescape(pic).include?("youtube")

		pic = URI.unescape(pic)
		starting = pic[(pic.index("url=")+4)...-1]
		pic = (starting.include?("?") ?  starting[0...starting.index("?")] : starting[0...starting.index("&")])
	
	elsif URI.unescape(pic).include?("http://www")	
		pic = URI.unescape(pic)

		starting = pic[pic.index("http://www")...-1]

		if starting.include?("jpg")
			pic = starting[0...(starting.index("jpg")+3)] 
		elsif starting.include?("png")
			pic = starting[0...(starting.index("png")+3)]
		end
		
	end

	pic
end

def read_updates_json
	updates = JSON.parse(File.readlines("json/updates.json")[0])
	p updates
end

def render_page
	@opening = %Q(
				<!DOCTYPE html>
				<html>
					<head>
						<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
						<title>Foosbake</title>
						<meta charset="UTF-8">
						<meta name="viewport" content="width=device-width, initial-scale=1">
						<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
						<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css" rel="stylesheet"/>
						<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Montserrat">
						<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
					</head>
					<script>
					function isScrolledIntoView(el) {
    					var elemTop = el.getBoundingClientRect().top;
    					var elemBottom = el.getBoundingClientRect().bottom;

    					var isVisible = (elemTop >= 0) && (elemBottom <= window.innerHeight);
    					return isVisible;
}
					</script>
					<style>
						body,h1 {font-family: "Montserrat", sans-serif}
						img {margin-bottom: -7px}
						.w3-row-padding img {margin-bottom: 12px}
						.w3-content{
    						display: flex;
  							flex-wrap: nowrap;
  							overflow-x: auto;
  							max-width:10000px;
  							-webkit-overflow-scrolling: touch;
  							-ms-overflow-style: -ms-autohiding-scrollbar; 
						}
						.w3-third{
							flex: 0 0 auto;
							margin-top: 5vh;
						}
						.navbar{font-size: 22px;
							padding: 5px 10px;
							width: 100vw;
							position:fixed;
						}
						.navitem{
							width:85%;
							text-align: center;
    						font-size: 1.5rem;
    						border-bottom: 3px solid rgba(0,0,0,0.1);
    						font-size: 1.5rem;
    						margin-left: 5%;
    						padding-bottom: 5px;
						}
						.scrolltext {
							float:right;
							margin-right: 5px;
							font-size: 12px;
						}
						.np-icon {margin-right:5px;min-width:20px;}
						.mybutton {
						  color: black;
						  display: inline-block; /* Inline elements with width and height. TL;DR they make the icon buttons stack from left-to-right instead of top-to-bottom */
						  position: relative; /* All 'absolute'ly positioned elements are relative to this one */
						  padding: 2px 5px; /* Add some padding so it looks nice */
						}
						.button__badge {
							  background-color: #fa3e3e;
							  border-radius: 2px;
							  color: white;
							  padding: 1px 3px;
							  font-size: 10px;
							  position: absolute; /* Position the badge within the relatively positioned button */
							  top: 0;
							  right: 0;
							}
						.new_stories {margin-right:20px;min-width:50px;font-size:24px;background-color:red;color:white;border-radius:25px;}
						.story{
							overflow-x:hidden;
							border-bottom: 2px dotted gray;
							padding:0 5px 0 5px;
							margin:0 1em 0 1em;
						}
					</style>
					<body>
						<div class="navbar"><span class='scrolltext'>Scroll right -></span></div>
						<div class="w3-content">
								<div class='w3-third' style='overflow: auto; max-height: 100vh;'>	
				  )

		@closing = %Q(	
								</div>
						</div>
					</body>
				</html>
			)

	ARTISTS.each do |artist|

		new_story_count_artist = read_updates_json.select{|o|o.keys.first==artist['name']}.first
		new_story_count = new_story_count_artist.values.first

		notification_span = (new_story_count.to_i==0 ? \
							"" : \
							"<span class='button__badge'>#{new_story_count}</span>")

		@opening += "<div class='navitem' >
						#{artist['name']}
						<div class='mybutton'>
    						<i class='fa fa-comments'></i>
							#{notification_span}
						</div>
					</div>"
		
		data = File.readlines("json/#{artist['file']}")

		size = JSON.parse(data[0]).length
		puts "#{artist['name']}: #{size} items"
		puts ("*" * size)
		
		data.each do |d|
			
			obj = JSON.parse(d)
			obj.each_with_index do |item,index|
				print("*") 

				extrastyle = (item==obj.first ? 'margin-top:2em;' : '')

				date = Date.parse(item['updated_time']).strftime("%A, %d %b %Y")
				from = "#{item['from']['name']}"
				header = item['type']
				icon = $icons[header.to_sym]

				message = item['message']

				pic = resolve_image(item)

				if pic.include?('default') 
					picwidth = 1280 
				else 
					dimensions = FastImage.size(pic)

					if dimensions.nil?
						picwidth = 0
					else
						picwidth = dimensions[0]
					end
				end

				picstyle = (picwidth < 300 ? "auto" : "90%")
				photo = "<img src='#{pic}' style='width:#{picstyle};text-align:center;' />"
	
				@opening += %Q( 
								<div class='story' style='#{extrastyle}'>
									<h5><span>#{from}</span></h5>
									<h6 style='width:100%;'><span>#{date}</span><span class='np-icon' style='float:right;'><img src='#{icon}' alt='#{header} icon' title='#{header}'/></span></h6>
									<a href='#{item["link"]}' style='font-decoration:none;'>
										#{photo}
									</a>
										<p style='font-size:0.9em;overflow:hidden;'>#{message}</p>
								</div>
							)		
			end
		end 

		unless artist==ARTISTS.last 
			@opening +=%Q(</div><div class='w3-third' style='overflow: auto; max-height: 100vh;'>)
		end

		print "\n"
	end

	all_data = @opening + @closing

	save_file_as(all_data, 'index.html')

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




