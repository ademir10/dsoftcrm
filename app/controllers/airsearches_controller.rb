class AirsearchesController < ApplicationController
  before_action :set_airsearch, only: [:show, :edit, :update, :destroy]
  before_action :show_question, only: [:show, :new, :edit, :update, :destroy]
  before_action :show_user, only: [:new, :edit]
  before_action :must_login

  #para atualizar os dados como o status, agendamento e inserir arquivos para upload
  def update_status_air
    
    @airsearch = Airsearch.find(params[:id])
    
    #VERIFICA SE A DATA INFORMADA É RETROATIVA - NÃO PODE LANÇAR AGENDAMENTOS COM DATAS RETROATIVAS!
    if airsearch_params[:schedule].present? && airsearch_params[:schedule].to_date <= Date.today
      flash[:warning] = 'Não é permitido o agendamento com data retroativa ou data atual! verifique a data informada.'
      redirect_to airsearch_path(@airsearch) and return
    end
    
    #é obrigatória a informação do status e valor cotado
    if airsearch_params[:status].blank? || airsearch_params[:cotation_value].blank?
      flash[:warning] = 'Em qualquer gerenciamento a informação do Valor cotado e o Status são obrigatórias, volte ao gerenciamento e atualize os dados!'
      redirect_to airsearch_path(@airsearch) and return
    end
    
    #se o cliente COMPROU
    if airsearch_params[:status] == 'COMPROU'
    
    Airsearch.update(params[:id],cotation_value: airsearch_params[:cotation_value] ,status: 'COMPROU', finished: 'SIM')
           
    #vai na agenda e exclui todos os agendamentos deste cliente
     Meeting.where(research_id: params[:id]).where(clerk_id: current_user.id).delete_all
    
    #ESTE BLOCO DE CODE É UTILIZADO PARA ATUALIZAR AS METAS DO USUÁRIO E ADMINISTRADOR SEMPRE QUE CRIAR/ATUALIZAR/DELETAR PESQUISA
        #calculando o total de agendamentos do dia
        @total_qnt = Meeting.where(start_time: Date.today).where(clerk_id: current_user.id).where(status: 'EM ANDAMENTO').count
                  
        #calcula os totais por categoria de pesquisa com base no usuário logado
        @total_rodo = Rodosearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_air = Airsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_pack = Packsearch.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(user_id: current_user.id).where(finished: 'SIM').sum(:cotation_value)
        @total_meeting = Meeting.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where(clerk_id: current_user.id).where(status: 'COMPROU').sum(:cotation_value)
        @total_research = @total_rodo.to_f + @total_air.to_f + @total_pack.to_f + @total_meeting.to_f
        @total_research = @total_research.round(2)
        #calcula o percentual já vendido do usuário logado
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
        log.task = 'Finalizou compra de pesquisa - Transporte Aéreo / Cliente ' + @airsearch.client.to_s
        log.save!
    
    flash[:success] = 'Parabens pelo excelente desempenho ' + current_user.name + '! ' + 'Este processo já foi finalizado com sucesso, e ai vamos para o próximo desafio?'
    redirect_to meetings_path and return  
    end
    
    #se o cliente está EM ANDAMENTO ele obrigatóriamente precisa fazer um agendamento caso não tenha feito ainda nenhum
    #com data posterior a data atual
    if airsearch_params[:status] == 'EM ANDAMENTO' && airsearch_params[:schedule].blank?
      check_meeting = Meeting.where(research_id: @airsearch).where("research_path LIKE ?", "%#{'airsearch'}%").order("start_time DESC").first
      
      #se não tiver nenhum agendamento feito
      if check_meeting.blank?
        flash[:warning] = 'Você precisa informar uma data de agendamento para um próximo contato, não existe nenhum agendamento para este cliente.'
        redirect_to airsearch_path(@airsearch) and return
      end
      
      #se tiverem agendamentos somente com datas retroativas ao dia de hoje
      if check_meeting.present? && check_meeting.start_time.to_date <= Date.today
        flash[:warning] = 'Você precisa informar uma data de agendamento para um próximo contato, não existe nenhum agendamento com data posterior a hoje para este cliente.'
        redirect_to airsearch_path(@airsearch) and return
      end
    end
    
    if airsearch_params[:status].blank? && airsearch_params[:schedule].blank?
      flash[:warning] = 'Informe o Status e se for o caso uma data para agendamento!'
      redirect_to airsearch_path(@airsearch) and return
    end
        
    @airsearch.update(airsearch_params)
    
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
    
    #verifica se a data para um novo agendamento foi inserida
    #só faz o agendamento automático se a data for informada com uma data posterior a data atual
   if airsearch_params[:schedule].present? && airsearch_params[:schedule].to_date > Date.today
      airsearch = Airsearch.find(params[:id])
      meeting = Meeting.new(params[:meeting])
      meeting.client = airsearch.client
      meeting.phone = airsearch.phone
      meeting.cotation_value = airsearch.cotation_value
      meeting.status = airsearch.status
      meeting.type_client = airsearch.type_client
      meeting.start_time = airsearch_params[:schedule]
      meeting.clerk_id = current_user.id
      meeting.clerk_name = current_user.name
      meeting.research_path = 'airsearches' + '/' + params[:id]
      meeting.research_id = params[:id]
      meeting.type_client = @airsearch.type_client
      meeting.save!
      
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Gerenciou pesquisa - Transporte Aéreo com agendamento para ' + airsearch_params[:schedule].to_time.strftime("%d/%m/%Y") + ' / Cliente ' + @airsearch.client.to_s
        log.save!
        
      flash[:success] = 'Os dados foram atualizados com sucesso e agendado um compromisso para o dia ' + airsearch_params[:schedule].to_time.strftime("%d/%m/%Y")
    elsif
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Gerenciou pesquisa atualizando dados - Transporte Aéreo / Cliente ' + @airsearch.client.to_s
        log.save!
      
    flash[:success] = 'Os dados foram atualizados com sucesso!' 
    end  
    #pego o id da pesquisa pra chamar a view
    id_airsearch = params[:id]  
    redirect_to airsearch_path(id_airsearch) and return

  end

  #gerenciamento da pesquisa
  def manage_air
  
  @result = Airsearch.find_by(id: params[:air_id])
  
  #apresenta sempre a data vazia para forçar o funcionário á fazer um novo agendamento nos casos de EM ANDAMENTO
  @result.schedule = nil 
 
  #se não tiver nada ainda cadastrado nas tratativas ai é forçado que o funcionário marque pelo menos uma opção
  if @result.solution_applied.blank?
  
    #primeiro verifica se foi selecionada pelo menos uma tratativa
    if params[:t1].blank? && params[:t2].blank? && params[:t3].blank? && params[:t4].blank? && params[:t5].blank? && params[:t6].blank? && params[:t7].blank? && params[:t8].blank? && params[:t9].blank? && params[:t10].blank? && params[:t11].blank? && params[:t12].blank?
      flash[:warning] = 'Você não selecionou nenhuma das tratativas propostas, selecione a(s) tratativa(s) adequada(s) para este cliente!'
      redirect_to airsearch_path(@result) and return
    end
        
        #concatenando as tratativas escolhidas para serem aplicadas
        if params[:t1].present?
        @solutions = params[:t1].to_s + "\n"
        end
        if params[:t2].present?
        @solutions = @solutions.to_s + params[:t2].to_s + "\n"
        end
        if params[:t3].present?
        @solutions = @solutions.to_s + params[:t3].to_s + "\n"
        end
        if params[:t4].present?
        @solutions = @solutions.to_s + params[:t4].to_s + "\n"
        end
        if params[:t5].present?
        @solutions = @solutions.to_s + params[:t5].to_s + "\n"
        end
        if params[:t6].present?
        @solutions = @solutions.to_s + params[:t6].to_s + "\n"
        end
        if params[:t7].present?
        @solutions = @solutions.to_s + params[:t7].to_s + "\n"
        end
        if params[:t8].present?
        @solutions = @solutions.to_s + params[:t8].to_s + "\n"
        end
        if params[:t9].present?
        @solutions = @solutions.to_s + params[:t9].to_s + "\n"
        end
        if params[:t10].present?
        @solutions = @solutions.to_s + params[:t10].to_s + "\n"
        end
        if params[:t11].present?
        @solutions = @solutions.to_s + params[:t11].to_s + "\n"
        end
        if params[:t12].present?
        @solutions = @solutions.to_s + params[:t12].to_s + "\n"
        end
      
      @result.solution_applied = @solutions
   end
  end

  def index
  if params[:tipo_consulta].blank?  
    @airsearches = Airsearch.order(:created_at, :client).where('finished = ?', 'NÃO').where(user_id: current_user.id).limit(50)
  else
    if params[:search] && params[:tipo_consulta] == "1"
          @airsearches = Airsearch.where("client like ?", "%#{params[:search]}%")
                                          
            elsif params[:search] && params[:tipo_consulta] == "2"
                @airsearches = Airsearch.where("phone like ?", "%#{params[:search]}%")
           
        end
    end
    
  end

  # GET /airsearches/1
  # GET /airsearches/1.json
  def show
    #carregando o cabeçalho, as perguntas e respostas
    @airsearches = Airsearch.where(id: params[:id])
    @q1 = Answer.find_by(id: @airsearch.q1)
    @q2 = Answer.find_by(id: @airsearch.q2)
    @q3 = Answer.find_by(id: @airsearch.q3)
    @q4 = Answer.find_by(id: @airsearch.q4)
    @q5 = Answer.find_by(id: @airsearch.q5)
    @q6 = Answer.find_by(id: @airsearch.q6)
    @q7 = Answer.find_by(id: @airsearch.q7)
    @q8 = Answer.find_by(id: @airsearch.q8)
    @q9 = Answer.find_by(id: @airsearch.q9)
    @q10 = Answer.find_by(id: @airsearch.q10)
    @q11 = Answer.find_by(id: @airsearch.q11)
    @q12 = Answer.find_by(id: @airsearch.q12)
    
    #faz o calculo do score pra saber se o cliente é quente, morno ou frio
    score1 = Answer.find_by(id: @airsearch.q1)
    score2 = Answer.find_by(id: @airsearch.q2)
    score3 = Answer.find_by(id: @airsearch.q3)
    score4 = Answer.find_by(id: @airsearch.q4)
    score5 = Answer.find_by(id: @airsearch.q5)
    score6 = Answer.find_by(id: @airsearch.q6)
    score7 = Answer.find_by(id: @airsearch.q7)
    score8 = Answer.find_by(id: @airsearch.q8)
    score9 = Answer.find_by(id: @airsearch.q9)
    score10 = Answer.find_by(id: @airsearch.q10)
    score11 = Answer.find_by(id: @airsearch.q11)
    score12 = Answer.find_by(id: @airsearch.q12)
    
    #pegando os ranges e quantidade de pesquisas cadastrados na categoria criada
    @ranges = Category.find_by(link: 'airsearches')
    
    @total_score = score1.score.to_i + score2.score.to_i + score3.score.to_i + score4.score.to_i + score5.score.to_i + score6.score.to_i + score7.score.to_i + score8.score.to_i + score9.score.to_i + score10.score.to_i + score11.score.to_i + score12.score.to_i
    @total_score = @total_score.fdiv(@ranges.qnt_question.to_i).round(2)
    
    #exibe as tratativas
    @show_solution1 = Solution.find_by(answer_id: @q1)
    @show_solution2 = Solution.find_by(answer_id: @q2)
    @show_solution3 = Solution.find_by(answer_id: @q3)
    @show_solution4 = Solution.find_by(answer_id: @q4)
    @show_solution5 = Solution.find_by(answer_id: @q5)
    @show_solution6 = Solution.find_by(answer_id: @q6)
    @show_solution7 = Solution.find_by(answer_id: @q7)
    @show_solution8 = Solution.find_by(answer_id: @q8)
    @show_solution9 = Solution.find_by(answer_id: @q9)
    @show_solution10 = Solution.find_by(answer_id: @q10)
    @show_solution11 = Solution.find_by(answer_id: @q11)
    @show_solution12 = Solution.find_by(answer_id: @q12)
  end

  # GET /airsearches/new
  def new
    @airsearch = Airsearch.new
    
  end

  # GET /airsearches/1/edit
  def edit
  end

  # POST /airsearches
  # POST /airsearches.json
  def create
   @airsearch = Airsearch.new(airsearch_params)
   #verifica se todos os campos estão preenchidos
   if airsearch_params[:client].blank? || airsearch_params[:phone].blank? || airsearch_params[:q1].blank? || airsearch_params[:q2].blank? || airsearch_params[:q3].blank? || airsearch_params[:q4].blank? || airsearch_params[:q5].blank? || airsearch_params[:q6].blank? || airsearch_params[:q7].blank? || airsearch_params[:q8].blank? || airsearch_params[:q9].blank? || airsearch_params[:q10].blank? || airsearch_params[:q11].blank? || airsearch_params[:q12].blank?
     flash[:warning] = 'Os dados do cliente e todas as perguntas precisam ser respondidas!'
     redirect_to new_airsearch_path and return
   end
    
    respond_to do |format|
      @airsearch.user_id = current_user.id
      @airsearch.user = current_user.name
      @airsearch.status = 'NÃO DEFINIDO'
      @airsearch.finished = 'NÃO'
      
      if @airsearch.save
        
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
        log.task = 'Cadastrou nova pesquisa - Transporte Aéreo / Cliente ' + airsearch_params[:client].to_s
        log.save!
        
        #faz o calculo do score pra atualizar o tipo de cliente na tabela
        score1 = Answer.find_by(id: airsearch_params[:q1])
        score2 = Answer.find_by(id: airsearch_params[:q2])
        score3 = Answer.find_by(id: airsearch_params[:q3])
        score4 = Answer.find_by(id: airsearch_params[:q4])
        score5 = Answer.find_by(id: airsearch_params[:q5])
        score6 = Answer.find_by(id: airsearch_params[:q6])
        score7 = Answer.find_by(id: airsearch_params[:q7])
        score8 = Answer.find_by(id: airsearch_params[:q8])
        score9 = Answer.find_by(id: airsearch_params[:q9])
        score10 = Answer.find_by(id: airsearch_params[:q10])
        score11 = Answer.find_by(id: airsearch_params[:q11])
        score12 = Answer.find_by(id: airsearch_params[:q12])
        
        #pegando os ranges e quantidade de pesquisas cadastrados na categoria criada
        @ranges = Category.find_by(link: 'airsearches')
        
        @total_score = score1.score.to_i + score2.score.to_i + score3.score.to_i + score4.score.to_i + score5.score.to_i + score6.score.to_i + score7.score.to_i + score8.score.to_i + score9.score.to_i + score10.score.to_i + score11.score.to_i + score12.score.to_i
        @total_score = @total_score.fdiv(@ranges.qnt_question.to_i).round(2)
        
        check_score = Airsearch.find_by(id: @airsearch)
                    
              if @total_score > @ranges.r1.to_f && @total_score <= @ranges.r2.to_f
              check_score.update_attributes(type_client: 'FRIO')
              elsif @total_score >= @ranges.r3.to_f && @total_score <= @ranges.r4.to_f
              check_score.update_attributes(type_client: 'MORNO') 
              elsif @total_score >= @ranges.r5.to_f && @total_score <= @ranges.r6.to_f
              check_score.update_attributes(type_client: 'QUENTE')
              end  
                
        #cadastrando automáticamente esse cliente pesquisado no cadastro de clientes
        client = Client.new(params[:client])
        client.name = airsearch_params[:client]
        client.cellphone = airsearch_params[:phone]
        client.save!
                      
        format.html { redirect_to @airsearch, notice: 'Pesquisa criada com sucesso.' }
        format.json { render :show, status: :created, location: @airsearch }
      else
        format.html { render :new }
        format.json { render json: @airsearch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /airsearches/1
  # PATCH/PUT /airsearches/1.json
  def update
    
    if airsearch_params[:user].blank? || airsearch_params[:client].blank? || airsearch_params[:phone].blank?
     flash[:warning] = 'Selecione o atendente e informe o nome e Celular do cliente!'
     redirect_to edit_airsearch_path(@airsearch) and return
    end
        
    #atualizando o atendente caso tenha sido feita a alteração para outro atendente
    if airsearch_params[:user] != current_user.name
    go_update = 'yes'  
    @id_usuario = User.find_by(name: airsearch_params[:user])
    end 
    
    respond_to do |format|
      if @airsearch.update(airsearch_params)
        
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
        log.task = 'Gerenciou pesquisa atualizando dados - Transporte Aéreo / Cliente ' + @airsearch.client.to_s
        log.save!
        
        #faz o calculo do score pra atualizar o tipo de cliente na tabela
        score1 = Answer.find_by(id: airsearch_params[:q1])
        score2 = Answer.find_by(id: airsearch_params[:q2])
        score3 = Answer.find_by(id: airsearch_params[:q3])
        score4 = Answer.find_by(id: airsearch_params[:q4])
        score5 = Answer.find_by(id: airsearch_params[:q5])
        score6 = Answer.find_by(id: airsearch_params[:q6])
        score7 = Answer.find_by(id: airsearch_params[:q7])
        score8 = Answer.find_by(id: airsearch_params[:q8])
        score9 = Answer.find_by(id: airsearch_params[:q9])
        score10 = Answer.find_by(id: airsearch_params[:q10])
        score11 = Answer.find_by(id: airsearch_params[:q11])
        score12 = Answer.find_by(id: airsearch_params[:q12])
        
        #pegando os ranges e quantidade de pesquisas cadastrados na categoria criada
        @ranges = Category.find_by(link: 'airsearches')
        
        @total_score = score1.score.to_i + score2.score.to_i + score3.score.to_i + score4.score.to_i + score5.score.to_i + score6.score.to_i + score7.score.to_i + score8.score.to_i + score9.score.to_i + score10.score.to_i + score11.score.to_i + score12.score.to_i
        @total_score = @total_score.fdiv(@ranges.qnt_question.to_i).round(2)
        
        check_score = Airsearch.find_by(id: @airsearch)
                    
        #se houve alteração de atendente é atualizado na pesquisa e na agenda
        if go_update == 'yes'
        check_score.update_attributes(user_id: @id_usuario.id)
        #pegando os dados lá na agenda pra atualizar o id do atendente trocado na pesquisa
        @caminho = 'airsearches/' + @airsearch.id.to_s
        meeting_data = Meeting.where(research_path: @caminho)
        meeting_data.update_all(clerk_id: @id_usuario.id, clerk_name: airsearch_params[:user], client: airsearch_params[:client])
        end 
        
        #para atualizar sempre na pesquisa o perfil do cliente quando a pesquisa for editada
        @caminho = 'airsearches/' + @airsearch.id.to_s
        meeting_data = Meeting.find_by(research_path: @caminho)  
                    
              if @total_score > @ranges.r1.to_f && @total_score <= @ranges.r2.to_f
              check_score.update_attributes(type_client: 'FRIO')
                #só atualiza na agenda se já existe agendamentos lá
                if meeting_data.present?
                meeting_data.update_attributes(type_client: 'FRIO')
                end
              elsif @total_score >= @ranges.r3.to_f && @total_score <= @ranges.r4.to_f
              check_score.update_attributes(type_client: 'MORNO')
                #só atualiza na agenda se já existe agendamentos lá
                if meeting_data.present?
                meeting_data.update_attributes(type_client: 'MORNO')
                end 
              elsif @total_score >= @ranges.r5.to_f && @total_score <= @ranges.r6.to_f
              check_score.update_attributes(type_client: 'QUENTE')
                #só atualiza na agenda se já existe agendamentos lá
                if meeting_data.present?
                meeting_data.update_attributes(type_client: 'QUENTE')
                end
              end
                 
        format.html { redirect_to @airsearch, notice: 'Pesquisa atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @airsearch }
      else
        format.html { render :edit }
        format.json { render json: @airsearch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /airsearches/1
  # DELETE /airsearches/1.json
  def destroy
    @airsearch.destroy
    Document.destroy_all(owner: @airsearch)
    Meeting.destroy_all(research_id: @airsearch)
    
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
        log.task = 'Excluiu pesquisa - Transporte Aéreo / Cliente ' + @airsearch.client.to_s
        log.save!
        
    respond_to do |format|
      format.html { redirect_to airsearches_url, notice: 'Pesquisa Excluida com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_airsearch
      @airsearch = Airsearch.find(params[:id])
      
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def airsearch_params
      params.require(:airsearch).permit(:user, :client, :phone, :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9, :q10, :q11, :q12, :status, :obs, :schedule, :reason, :pains, :solution_applied, :cotation_value, :finished, :user_id)
    end
    
    def show_question
      
      @question1 = Question.find_by(id: '14')
      @question2 = Question.find_by(id: '15')
      @question3 = Question.find_by(id: '16')
      @question4 = Question.find_by(id: '17')
      @question5 = Question.find_by(id: '18')
      @question6 = Question.find_by(id: '19')
      @question7 = Question.find_by(id: '20')
      @question8 = Question.find_by(id: '21')
      @question9 = Question.find_by(id: '22')
      @question10 = Question.find_by(id: '23')
      @question11 = Question.find_by(id: '24')
      @question12 = Question.find_by(id: '25')
      
      
      if @question1.blank? || @question2.blank? || @question3.blank? || @question4.blank? || @question5.blank? || @question6.blank? || @question7.blank? || @question8.blank? || @question9.blank? || @question10.blank? || @question11.blank? || @question12.blank?
      flash[:warning] = "Você precisa cadastrar primeiro as 12 perguntas e respostas com as tratativas para esta pesquisa!"
      redirect_to questions_path and return
      end  
           
    end
    def show_user
      @users = User.where('type_access != ?', 'MASTER').order(:name)
    end
    
end
