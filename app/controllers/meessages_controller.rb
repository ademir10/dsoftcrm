class MeessagesController < ApplicationController
  
  before_action :must_login
  
  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.meessages.build(meessage_params)
    @message.user_id = current_user.id
    @message.save!

    @path = conversation_path(@conversation)
  end

  private

  def meessage_params
    params.require(:meessage).permit(:body)
  end
  
end
