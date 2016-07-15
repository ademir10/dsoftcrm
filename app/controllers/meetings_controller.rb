class MeetingsController < ApplicationController
  before_action :set_meeting, only: [:show, :edit, :update, :destroy]
  before_action :show_user, only: [:index, :new, :edit, :create]

  # GET /meetings
  # GET /meetings.json
  def index
    
    #se for um usuario com perfil de administrador ele pode selecionar a agenda desejada por fucionario
    #ou exibir o agendamento de todos
    if params[:user_id].present?
    @meetings = Meeting.where(clerk_id: params[:user_id]).where('status != ?', 'COMPROU')
    elsif params[:user_id].blank?
    @meetings = Meeting.where('status != ?', 'COMPROU')
    end
    
    #se não tiver filtro e for um mero usuario é carregado somente os agendamentos dele
    if current_user.type_access == 'USER'
    @meetings = Meeting.where(clerk_id: current_user.id).where('status != ?', 'COMPROU')
    end
    
    if params[:week].present?
      @week = 'SIM'
    else
      @week = 'NÃO'
    end
    
  end

  # GET /meetings/1
  # GET /meetings/1.json
  def show
  end

  # GET /meetings/new
  def new
    @meeting = Meeting.new
  end

  # GET /meetings/1/edit
  def edit
  end

  # POST /meetings
  # POST /meetings.json
  def create
    @meeting = Meeting.new(meeting_params)
    #verifica se a data é anterior a data atual
    if @meeting.start_time.present? && @meeting.start_time < Date.today
      flash[:warning] = 'A data para agendamento não pode ser inferior a data atual, verifique os dados!'
      redirect_to new_meeting_path and return
    end
    
    #se marcar COMPROU é obrigatório informar o valor da venda
    if @meeting.status == 'COMPROU' && @meeting.cotation_value.blank?
      flash[:warning] = 'Não é possivel finalizar um atendimento onde ocorreu a compra sem informar o valor, verifique os dados!'
      redirect_to new_meeting_path and return
    end
           
     respond_to do |format|
      #inseri a linha abaixo pra garantir que o id do user fosse salvo, pq notei que se esquecer de informar data
      #o campo do id do usuario fica em branco 
      
      @meeting.clerk_id = current_user.id 
      if @meeting.save
      #pegando o id que foi salvo pra montar o path do agendamento
       Meeting.update(@meeting.id, research_path: 'meetings' + '/' + @meeting.id.to_s, research_id: @meeting.id)
       
       #cadastrando automáticamente esse cliente pesquisado no cadastro de clientes
        client = Client.new(params[:client])
        client.name = meeting_params[:client]
        client.cellphone = meeting_params[:phone]
        client.save!
        
     #ESTE BLOCO DE CODE É UTILIZADO PARA ATUALIZAR AS METAS DO USUÁRIO SEMPRE QUE CRIAR/ATUALIZAR/DELETAR PESQUISA
        #calculando o total de agendamentos do dia
        @total_qnt = Meeting.where(start_time: Date.today).where(clerk_id: current_user.id).where(status: 'EM ANDAMENTO').count
                  
        #calcula os totais por categoria de pesquisa com base no usuário logado
        @total_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(clerk_id: current_user.id).where(status: 'COMPROU').sum(:cotation_value)
        @total_research = @total_rodo.to_f + @total_air.to_f + @total_pack.to_f + @total_meeting.to_f
        @total_research = @total_research.round(2)
        #calcula o percentual já vendido
        @current_goal = (@total_research.to_f / current_user.goal.to_f) * 100
        @current_goal = @current_goal.round(2)
        
        #atualiza os dados de meta mensal do usuário
        User.update(current_user.id, qnt_research: @total_qnt.to_i, total_sale: @total_research, current_percent: @current_goal.to_f)
        
        #calculando o total de agendamentos do dia
        t_qnt = Meeting.where(start_time: Date.today).where(status: 'EM ANDAMENTO').count
        #calcula o total geral vendido e atualiza o já vendido do ADMINISTRADOR 
        #calcula os totais por categoria de pesquisa com base no usuário logado
        t_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(status: 'COMPROU').sum(:cotation_value)
        t_research = t_rodo.to_f + t_air.to_f + t_pack.to_f + t_meeting.to_f
        t_research = t_research.round(2)
        
        #localiza o total de metas cadastrado no usuário ADMIN
        goal_admin = User.where(type_access: 'ADMIN').first
        
        #calcula o percentual já vendido geral para o ADMIN
        c_goal = (t_research.to_f / goal_admin.goal.to_f) * 100
        c_goal = c_goal.round(2)
        #atualiza os dados de meta mensal do usuário
        User.where(type_access: 'ADMIN').update_all(qnt_research: t_qnt, total_sale: t_research, current_percent: c_goal.to_f)
      #-----------------------------------FIM DO BLOCO-------------------------------------------------------------
        
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Cadastrou novo Agendamento / Cliente ' + meeting_params[:client].to_s
        log.save!
       
       if @meeting.status == 'COMPROU'
        flash[:success] = 'Parabens pelo excelente desempenho ' + current_user.name + '! ' + 'Este processo já foi finalizado com sucesso, e ai vamos para o próximo desafio?'
        redirect_to meetings_path and return
        else
        format.html { redirect_to @meeting, notice: 'Agendamento criado com sucesso.' }
        format.json { render :show, status: :created, location: @meeting }  
       end 
         
        
      else
        format.html { render :new }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /meetings/1
  # PATCH/PUT /meetings/1.json
  def update
    
    #se marcar COMPROU é obrigatório informar o valor da venda
    if meeting_params[:status] == 'COMPROU' && meeting_params[:cotation_value].blank?
    flash[:warning] = 'Não é possivel finalizar um atendimento onde ocorreu a compra sem informar o valor, verifique os dados!'
      redirect_to meeting_path(meeting_params) and return
    end
    
    #atualizando o atendente caso tenha sido feita a alteração para outro atendente
    if meeting_params[:clerk_name] != current_user.name
    go_update = 'yes'  
    @id_usuario = User.find_by(name: meeting_params[:clerk_name])
    end 

    respond_to do |format|
      if @meeting.update(meeting_params)
        
        check_meeting = Meeting.find_by(id: @meeting)
                    
        #se houve alteração de atendente é atualizado na pesquisa e na agenda
        if go_update == 'yes'
        check_meeting.update_attributes(clerk_id: @id_usuario.id)
        #pegando os dados lá na agenda pra atualizar o id do atendente trocado na pesquisa
        @caminho = 'meetings/' + @meeting.id.to_s
        meeting_data = Meeting.find_by(research_path: @caminho)
        meeting_data.update_attributes(clerk_id: @id_usuario.id)
        end 
        
     #ESTE BLOCO DE CODE É UTILIZADO PARA ATUALIZAR AS METAS DO USUÁRIO SEMPRE QUE CRIAR/ATUALIZAR/DELETAR PESQUISA
        #calculando o total de agendamentos do dia
        @total_qnt = Meeting.where(start_time: Date.today).where(clerk_id: current_user.id).where(status: 'EM ANDAMENTO').count
                  
        #calcula os totais por categoria de pesquisa com base no usuário logado
        @total_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(clerk_id: current_user.id).where(status: 'COMPROU').sum(:cotation_value)
        @total_research = @total_rodo.to_f + @total_air.to_f + @total_pack.to_f + @total_meeting.to_f
        @total_research = @total_research.round(2)
        #calcula o percentual já vendido
        @current_goal = (@total_research.to_f / current_user.goal.to_f) * 100
        @current_goal = @current_goal.round(2)
        
        #atualiza os dados de meta mensal do usuário
        User.update(current_user.id, qnt_research: @total_qnt.to_i, total_sale: @total_research, current_percent: @current_goal.to_f)
        
        #calculando o total de agendamentos do dia
        t_qnt = Meeting.where(start_time: Date.today).where(status: 'EM ANDAMENTO').count
        #calcula o total geral vendido e atualiza o já vendido do ADMINISTRADOR 
        #calcula os totais por categoria de pesquisa com base no usuário logado
        t_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(status: 'COMPROU').sum(:cotation_value)
        t_research = t_rodo.to_f + t_air.to_f + t_pack.to_f + t_meeting.to_f
        t_research = t_research.round(2)
        
        #localiza o total de metas cadastrado no usuário ADMIN
        goal_admin = User.where(type_access: 'ADMIN').first
        
        #calcula o percentual já vendido geral para o ADMIN
        c_goal = (t_research.to_f / goal_admin.goal.to_f) * 100
        c_goal = c_goal.round(2)
        #atualiza os dados de meta mensal do usuário
        User.where(type_access: 'ADMIN').update_all(qnt_research: t_qnt, total_sale: t_research, current_percent: c_goal.to_f)
      #-----------------------------------FIM DO BLOCO-------------------------------------------------------------
   
       #se comprou é direcionado para a agenda de compromissos
       if @meeting.status == 'COMPROU' && @meeting.cotation_value.present?
        #COMPROU
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Finalizou compra em agendamento / Cliente ' + @meeting.client.to_s
        log.save!
            
            flash[:success] = 'Parabens pelo excelente desempenho ' + current_user.name + '! ' + 'Este processo já foi finalizado com sucesso, e ai vamos para o próximo desafio?'
            redirect_to meetings_path and return
            else
           
        #ATUALIZOU DADOS
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Gerenciou agendamento atualizando dados / Cliente ' + @meeting.client.to_s
        log.save!  
              
            format.html { redirect_to @meeting, notice: 'Agendamento atualizado com sucesso.' }
          end
        format.json { render :show, status: :ok, location: @meeting }
      else
        format.html { render :edit }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /meetings/1
  # DELETE /meetings/1.json
  def destroy
    @meeting.destroy
    
     #ESTE BLOCO DE CODE É UTILIZADO PARA ATUALIZAR AS METAS DO USUÁRIO SEMPRE QUE CRIAR/ATUALIZAR/DELETAR PESQUISA
        #calculando o total de agendamentos do dia
        @total_qnt = Meeting.where(start_time: Date.today).where(clerk_id: current_user.id).where(status: 'EM ANDAMENTO').count
                  
        #calcula os totais por categoria de pesquisa com base no usuário logado
        @total_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(clerk_id: current_user.id).where(status: 'COMPROU').sum(:cotation_value)
        @total_research = @total_rodo.to_f + @total_air.to_f + @total_pack.to_f + @total_meeting.to_f
        @total_research = @total_research.round(2)
        #calcula o percentual já vendido
        @current_goal = (@total_research.to_f / current_user.goal.to_f) * 100
        @current_goal = @current_goal.round(2)
        
        #atualiza os dados de meta mensal do usuário
        User.update(current_user.id, qnt_research: @total_qnt.to_i, total_sale: @total_research, current_percent: @current_goal.to_f)
        
        #calculando o total de agendamentos do dia
        t_qnt = Meeting.where(start_time: Date.today).where(status: 'EM ANDAMENTO').count
        #calcula o total geral vendido e atualiza o já vendido do ADMINISTRADOR 
        #calcula os totais por categoria de pesquisa com base no usuário logado
        t_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(finished: 'SIM').sum(:cotation_value)
        t_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(status: 'COMPROU').sum(:cotation_value)
        t_research = t_rodo.to_f + t_air.to_f + t_pack.to_f + t_meeting.to_f
        t_research = t_research.round(2)
        
        #localiza o total de metas cadastrado no usuário ADMIN
        goal_admin = User.where(type_access: 'ADMIN').first
        
        #calcula o percentual já vendido geral para o ADMIN
        c_goal = (t_research.to_f / goal_admin.goal.to_f) * 100
        c_goal = c_goal.round(2)
        #atualiza os dados de meta mensal do usuário
        User.where(type_access: 'ADMIN').update_all(qnt_research: t_qnt, total_sale: t_research, current_percent: c_goal.to_f)
      #-----------------------------------FIM DO BLOCO-------------------------------------------------------------
    
    
    #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu agendamento / Cliente ' + @meeting.client.to_s
        log.save!
    
    #tive que fazer essa query junto com o delete pra escluir com dois parametros
    Document.where(owner: @meeting).where(type_research: params[:request]).delete_all
    flash[:success] = 'Agendamento excluido com sucesso.'
      redirect_to meetings_url and return
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_meeting
      @meeting = Meeting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def meeting_params
      params.require(:meeting).permit(:client, :phone, :status, :start_time, :clerk_id, :research_path, :research_id, :type_client, :obs, :cotation_value, :clerk_name)
    end
    
    def show_user
      @users = User.where('type_access != ?', 'MASTER').order(:name)
    end
end
