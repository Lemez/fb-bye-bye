USER ='lemez9'
PASS = 'Gm41lj0n'
$my_mail = 'lemez9@gmail.com'

RAMA = '101837289375'
SANJAY = '233353576678131'
CARNATIC = '15043053167'
BOMBAY = '1552867064939140'
RASIKAS = '2210833262'
MDR='137283749618848'

ARTISTS = [
					{'name' => 'Prince Rama Varma',
					'file' => 'varma.json',
					'var' => RAMA
					},
					{'name' => 'MDR',
					'file' => 'mdr.json',
					'var' => MDR
					},

					# {
					# 'name' => 'Bombay Jayashree',
					# 'file' => 'bombay.json',
					# 'var' => BOMBAY
					# },
					{
						'name' => 'Rasikas',
					'file' => 'rasikas.json',
					'var' => RASIKAS
					}


					# {
					# 	'name' => 'Sanjay Subramanian',
					# 'file' => 'sanjay.json',
					# 'var' => SANJAY
					# }
]

Koala.configure do |config|
  config.access_token = "EAACA8IqiOHQBABd0DIOZCJiRoiVXokQNSkm3MmsgmnImo0DOlh8lCdZBcBrlwHFdZB8ljmXx3MY6kx2dHioxFgqO8Gl7pXZBckZBAauPGWnYSugMjGPcdjmE8OZBXuXuI4IoW6GFHLSnvyTquF5htSI45pXfRsT5Ehm8nk0iZBQNmisq0LU4BcRkLy5wazDTUQZD"
  config.app_access_token = "141770606393460|B-8V3m208UUx8SnSs-ghJRjF3LA"
  config.app_id = '141770606393460'
  config.app_secret = '50660c4636d5082bd872e2600c4b2509'
  # See Koala::Configuration for more options, including details on how to send requests through
  # your own proxy servers.
end