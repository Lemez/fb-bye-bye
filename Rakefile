require 'rake'
require 'bundler'
require_relative ('config/constants')

task :update do |t|
	system "echo '*************'"
	puts Time.now
	system "ruby -r '#{SCRIPT_ROOT}/script.rb' -e 'update_html'"
end

