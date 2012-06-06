class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def success
  end

  def create
    @message = Message.new(params[:message])
    if @message.valid?
      # send message
			ContactMailer.new_message(@message).deliver
			@email_sent = true
      render "new"
    else
      render "new"
    end
  end
end
