if Rails.env.production?
	ActionMailer::Base.smtp_settings = {
		:address              => "smtp.gmail.com",
		:port                 => 587,
		:domain               => 'gmail.com',
		:user_name            => ENV['APP_ERROR_EMAIL_ADDRESS'],
		:password             => ENV['APP_ERROR_EMAIL_PASSWORD'],
		:authentication       => 'plain',
		:enable_starttls_auto => true
	}
end
