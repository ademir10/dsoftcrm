class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :show_category, only: [:show, :new, :edit, :update, :create]
  before_action :must_login
  
  def add_solution
    @answer = Answer.find_by(id: params[:id_answer])
    #@advices = Advice.order(:description)
    redirect_to new_solution_path
  end

  # GET /questions
  # GET /questions.json
  def index
    @show_category = Category.order(:name)
    
    if params[:category].present?
    @questions = Question.includes(:category).where('questions.category_id = ?', params[:category]).order('questions.description')    
    else 
    @questions = Question.includes(:category).order('updated_at DESC')  
    end

  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
              #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Cadastrou nova pergunta / Descrição: ' + question_params[:description].to_s
        log.save  
        
        format.html { redirect_to @question, notice: 'Pergunta criada com sucesso.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
      
              #ATUALIZOU DADOS
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Atualizou pergunta - Descrição: ' + @question.description.to_s
        log.save!
          
        format.html { redirect_to @question, notice: 'Pergunta atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu pergunta - Descrição: ' + @question.description.to_s
        log.save!
    
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Pergunta excluida com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:category_id, :description)
    end
    
    def show_category
      @categories = Category.where('link != ?', 'meetings/new').order(:name)
    end
end
