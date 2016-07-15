Rails.application.routes.draw do
  
  
  #para o chat
  resources :messengers
    
    resources :conversations do
    resources :meessages
  end
  
  
  resources :loginfos
  #pacote de viagens 
  resources :packsearches do
    member do
      get 'manage_pack'
      post 'update_status_pack'
    end
  end
  #transporte rodoviario
  resources :rodosearches do
  member do
      get 'manage_air'
      post 'update_status_air'
     end
  end  
  
  resources :meetings
  resources :clients
  resources :documents
  resources :solutions
  resources :questions do
  resources :answers 
  end
  
  resources :answers 
  
  #transporte aéreo
  resources :airsearches do
    member do
      get 'manage_air'
      post 'update_status_air'
      #get 'end_research'
    end
  end
  resources :categories
 resources :expire_dates
 resources :users
  
  
  #para exibir a imagem que foi feito o upload
  get 'show_file' => 'documents#show_file'
    
  root 'pages#index'
  get 'sessions/new'
  
  #rotas para o login
  get 'expired', to: 'sessions#expired_date'
  get 'pages/index'
  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  post 'login', to: 'sessions#create'
  #---------------------------------------------
  
  #rotas para contato
  get 'contact', to: 'messages#new', as: 'contact'
  post 'contact', to: 'messages#create'
  #---------------------------------------------
  #somente para chamar a edição do usuario quando for um membro logado
  get 'editar_user', to: 'users#chama_edicao'
  #---------------------------------------------
  
  #relatórios
  #relatorio de analises graficas
  get 'business_report', to: 'pages#business_report'
  #analises graficas de vendas por segmento de marketing
  get 'marketing_report', to: 'pages#marketing_report'
  #relatorio analitico de vendas
  get 'analitics_report', to: 'pages#analitics_report'
  #relatorio de pendencia de pesquisas com status "NÃO DEFINIDO"
  get 'pendencies_report', to: 'pages#pendencies_report'
  #grafico de vendas anual
  get 'sales_report', to: 'pages#sales_report'
      
  #para carregar a view informando que não pode excluir cadastro com relacionamento em outra table
  get 'message_error_relation_tables', to: 'messages#message_error_relation_tables'
  end


