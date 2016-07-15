module MeessagesHelper
  
  def self_or_other(meessage)
    meessage.user == current_user ? "self" : "other"
  end

  def meessage_interlocutor(meessage)
    meessage.user == meessage.conversation.sender ? meessage.conversation.sender : meessage.conversation.recipient
  end
  
end
