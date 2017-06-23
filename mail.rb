require 'net/smtp'
require 'mail'


require_relative('./secret.rb')

$mail_options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'auroville.org.in',     
            :user_name            => USER,
            :password             => PASS,
            :authentication       => 'plain',
            :enable_starttls_auto => true  }
            

Mail.defaults do
  delivery_method :smtp, $mail_options
end

def mail (usage,validity,myheader)
	
	to_address = $my_mail
	p "Delivering mail to #{to_address}"

	Mail.deliver do
       	to "#{to_address}"
     	from 'Dongle Bot'
  		subject myheader + ' for ' + Date.today.strftime("%B %d %Y")
     	
     	text_part do
		    body [usage,validity].join("\n")
		end

 	end
end

