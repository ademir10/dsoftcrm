class MessageMailer < ApplicationMailer
  
  default from: "Mensagem enviada - DsoftWeb - CRMWeb"
  default to: "contato@ddti.com.br"

  def new_message(message)
    @message = message
    
    mail subject: "Mensagem de #{message.name}"
  end
end
