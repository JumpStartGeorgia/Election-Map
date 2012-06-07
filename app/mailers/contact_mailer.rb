class ContactMailer < ActionMailer::Base
  default :from => ENV['APPLICATION_FEEDBACK_FROM_EMAIL']
  default :to => ENV['APPLICATION_FEEDBACK_TO_EMAIL']

  def new_message(message)
    @message = message
    mail(:cc => "#{message.name} <#{message.email}>", :subject => I18n.t("contact_mailer.subject"))
  end

end
