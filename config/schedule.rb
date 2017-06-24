SCRIPT_ROOT = "/Users/JW/Websites/fb-bye-bye"

set :output, "#{SCRIPT_ROOT}/log/cron_log.log"

every 2.hours do
	rake "update"
end

# Update from command line with "whenever --update-crontab"
# Learn more: http://github.com/javan/whenever

# Use this file to easily define all of your cron jobs.
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end