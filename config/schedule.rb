# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
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

# Learn more: http://github.com/javan/whenever

SCRIPT_ROOT = "/Users/JW/Websites/facebook-replace"

set :output, "#{SCRIPT_ROOT}/log/cron_log.log"
#
# with sending mail update

# without sending mail update
every 2.hours do
	command "echo '*************'"
	command "rvm use ruby-2.3.3"
	command "ruby -r '#{SCRIPT_ROOT}/script.rb' -e 'update_html'"
	command "echo '*************'"
end

# update with
# whenever --update-crontab
