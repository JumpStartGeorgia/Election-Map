class ContactMailer < ActionMailer::Base
  default :from => ENV['ELECTION_MAP_CONTACT_FROM_EMAIL']
  default :to => ENV['ELECTION_MAP_CONTACT_TO_EMAIL']

  def new_message(message)
    @message = message
    mail(:cc => "#{message.name} <#{message.email}>", :subject => I18n.t("contact_mailer.subject"))
  end

end
