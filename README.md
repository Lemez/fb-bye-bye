# What is this?

An application to replace the horrible Facebook web app. I would delete my FB account - for those living in caves, [some background on the sheer scariness](http://www.salimvirani.com/facebook) - were it not for two things:

    - messages from friends
    - messages on pages/groups of musicians I follow

I have the lovely desktop app [Franz](http://meetfranz.com/) to bring my Skype and FB Messenger conversations to one place. So I decided to write this app to bring the group and page posts I'm missing to my own clean desktop interface. 

It carries out a few simple steps:

    1. Queries the Facebook Graph API for 50 recent posts in the groups/pages I like
    2. Saves each page's posts in a separate text file called {{my-page-name.json}}
    3. Reads the json files and compiles them into a clean web page that I can read whenever I open a new tab
    4. Repeat every two hours.

Facebook's crappy interface - bye bye!

# How To Use

1. Go to the [Facebook developers site](https://developers.facebook.com/apps/) and add a new application
2. Create a _lib/koala.rb_ page with the following info from the new application settings page:   
     
        Koala.configure do |config|
            config.access_token = MY_ACCESS_TOKEN
            config.app_access_token = MY_APP_ACCESS_TOKEN
            config.app_id = MY_APP_ID
            config.app_secret = MY_APP_SECRET
        end

3. In _lib/pages.rb_, add relevant group or page details like this:

        ARTISTS = [
                    {'name' => 'Prince Rama Varma',
                    'file' => 'varma.json',
                    'page_id' => '101837289375'
                    },
                    
                    {'name' => 'MDR',
                    'file' => 'mdr.json',
                    'page_id' => '137283749618848'
                    }
                 ] 
You can get the page_id from [here](https://lookup-id.com/).

4.  Test that the API is working by manually running the functions *update_html* or *render_page* from Terminal when inside the directory. This will update the _index.html_ page, or provide some insightful errors if the project is not set up properly. To see if the API call is working properly and creating json files:
        
        ruby -r "./script.rb" -e "update_html"
or if you want to tamper with just the html/css: 

        ruby -r "./script.rb" -e "render_page"

5.  Update your computer's cron tab in order to make your machine request updates every few hours or days, according to the frequency specified in *config/schedule.rb* (current default is every 2 hours) 
        
        whenever --update-crontab
and check that the updating has worked by listing cron jobs: 
        
        crontab -l

6.  Download a [_Replace New Tab Page_ extension](https://chrome.google.com/webstore/detail/replace-new-tab-page/cnkhddihkmmiiclaipbaaelfojkmlkja) in the browser of your choice and direct it to */path/to/my/project/fb-bye-bye/index.html* in order to see your updated page every time you open a new browser tab. Happy days!


 


<!-- find FB group ID with https://lookup-id.com/ and copy-paste full url -->