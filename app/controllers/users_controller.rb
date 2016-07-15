class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  #bloqueando o acesso sem estar logado
  before_action :must_login, only: [:index, :show, :edit, :update, :destroy, :new]
  #verifica se o usuario é um usuario simples e bloqueia se tentar acessar as configurações de todos usuarios via url
  before_action :check_user_logged, only: [:index]
  #soma o valor total da meta do administrador com base na somatoria de metas de todos os vendedores
  before_action :sum_goal, only: [:new, :create, :edit, :update]
  

  #chama a edição do usuario que está logado
  def chama_edicao
     @id_user = current_user.id
    redirect_to edit_user_path(@id_user)
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.limit(10)
    @total_users = User.count
    
    if params[:search] && params[:tipo_consulta] == "1"
          @users = User.where("name like ?", "%#{params[:search]}%")
            
            elsif params[:search] && params[:tipo_consulta] == "2"
                @users = User.where("email like ?", "%#{params[:search]}%")
            
        end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    
    if @user.type_access == 'ADMIN'
      @user.goal = @total_goal
    end

    respond_to do |format|
      if @user.save
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Cadastrou novo usuário - Nome: ' + user_params[:name].to_s
        log.save!
        
              #Sends email to user when user is created.
      UserNotifier.send_signup_email(@user).deliver_now
        format.html { redirect_to @user }
        flash[:success] = 'Usuário criado com sucesso, os dados foram enviados para o email informado.'
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
  
  #VERIFICAR AQUI A POSSIBILIDADE DE ALTERAR O VALOR ANTES DO UPDATE  
    if user_params[:type_access] == 'ADMIN'
    user_params[:goal] == @total_goal
    end
    
    respond_to do |format|
      if @user.update(user_params)
                #ATUALIZOU DADOS
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Atualizou usuário - Nome: ' + @user.name.to_s
        log.save
        
        format.html { redirect_to @user, notice: 'Usuário atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu usuário - Nome: ' + @user.name.to_s
        log.save!
        
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Usuário excluido com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :type_access,:ccategory,:cresearch,:cquestion,:cadvice,:cuser, :mcli, :rbusiness, :ccli, :mmeeting, :ranalitic, :mlog, :goal, :qnt_research, :total_sale, :current_percent, :rpen, :rmark,:rsales)
    end
    
    #verifica o perfil do usuario
    def check_user_logged
      if current_user.type_access == 'User'
        flash[:danger] = 'Voçê não tem permissão para acessar essa pagina!'
        redirect_to root_path
      end
    end
    
    #meta total do administrator
    def sum_goal
      @total_goal = User.where(type_access: 'USER').sum(:goal)
    end
    
end
