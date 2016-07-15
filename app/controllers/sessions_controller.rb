class SessionsController < ApplicationController
  
  def expired_date
    #just to show expired view
  end
  
  def new
  end
  
  def create
             
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
    session[:user_id] = user.id
         
    if current_user.type_access != 'MASTER'
      #verifica se a licença de uso está ok somente se o usuario não for MASTER
      check_date = ExpireDate.first
      if check_date.active == true && check_date.date_expire <= Date.today 
      flash[:danger] = 'A sua licença expirou, por favor entre em contato com o suporte para adquirir uma nova licença.'
      session[:user_id] = nil
      redirect_to contact_path and return
      end
     end
     
      redirect_to meetings_path
    
    else
      flash[:danger] = "Email ou Senha incorretos, por favor verifique os dados."
      redirect_to root_path
      #render 'new'
    end
  end
  
  def destroy
    session[:user_id] = nil
    #flash[:success] = "See you soon!"
    redirect_to root_path
  end
  
end
