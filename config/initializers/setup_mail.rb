if Rails.env.production?
	ActionMailer::Base.smtp_settings = {  
		:address              => "smtp.gmail.com",  
		:port                 => 587,  
		:domain               => "jumpstart.ge",  
		:user_name            => ENV['ELECTION_MAP_EMAIL_USER'],  
		:password             => ENV['ELECTION_MAP_EMAIL_PWD'],  
		:authentication       => "plain",  
		:enable_starttls_auto => true  
	} 
end
