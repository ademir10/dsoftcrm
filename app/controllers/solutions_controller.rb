class SolutionsController < ApplicationController
  before_action :set_solution, only: [:show, :edit, :update, :destroy]
  before_action :show_question_answer, only: [:new]
  before_action :must_login
  # GET /solutions
  # GET /solutions.json
  def index
    
    if params[:search].present?
    @solutions = Solution.where("description LIKE ?", "%#{params[:search]}%").order(:description)  
    else 
    @solutions = Solution.includes(:answer).order(created_at: :desc)
    end
        
    
  end

  # GET /solutions/1
  # GET /solutions/1.json
  def show
  end

  # GET /solutions/new
  def new
    #verifica se já existe uma tratativa cadastrada para a pergunta, se já estiver, não deixa cadastrar outra tratativa
    check_solution = Solution.where(answer_id: params[:id_answer])
    if check_solution.present?
      flash[:warning] = 'Você já cadastrou uma tratativa para essa resposta!'
      redirect_to solutions_path and return
    end
    
     @solution = Solution.new
  end

  # GET /solutions/1/edit
  def edit
    #pra mostrar na view edit qual é a resposta que está amarrada á essa tratativa
    answer = Solution.find_by(id: @solution)
    @answer = Answer.find_by(id: answer.answer_id)
  end

  # POST /solutions
  # POST /solutions.json
  def create
    
    @solution = Solution.new(solution_params)

    respond_to do |format|
      if @solution.save
                #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Cadastrou nova tratativa - Descrição: ' + solution_params[:description].to_s
        log.save!
        
        format.html { redirect_to @solution, notice: 'Tratativa criada com sucesso.' }
        format.json { render :show, status: :created, location: @solution }
      else
        format.html { render :new }
        format.json { render json: @solution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /solutions/1
  # PATCH/PUT /solutions/1.json
  def update
    respond_to do |format|
      if @solution.update(solution_params)
               #ATUALIZOU DADOS
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Atualizou tratativa - Descrição ' + @solution.description.to_s
        log.save! 
        
        format.html { redirect_to @solution, notice: 'Tratativa atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @solution }
      else
        format.html { render :edit }
        format.json { render json: @solution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /solutions/1
  # DELETE /solutions/1.json
  def destroy
    @solution.destroy
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu tratativa / Descrição: ' + @solution.description.to_s
        log.save!
        
    respond_to do |format|
      format.html { redirect_to solutions_url, notice: 'Tratativa excluida com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_solution
      @solution = Solution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def solution_params
      params.require(:solution).permit(:answer_id, :description, :category_name)
    end
    
    def show_question_answer
      @answer = Answer.find_by(id: params[:id_answer])
    end
end
