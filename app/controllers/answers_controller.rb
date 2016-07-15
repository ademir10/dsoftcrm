class AnswersController < ApplicationController
  before_action :must_login

  def edit
    #redirect_to root_path and return
    @answer = Answer.find(params[:id_answer])
  end
  
    def create
    @question = Question.find(params[:question_id])
              
      if answer_params[:description].blank? || answer_params[:score].blank? 
     flash[:warning] = 'A descrição da resposta e o score precisam ser informados!'
     redirect_to question_path(@question) and return
     else 
      @answer = @question.answers.create(answer_params)
      redirect_to question_path(@question)
      
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Cadastrou nova resposta - ' + answer_params[:description].to_s
        log.save!
     end
    end
    
    def update
      
      @answer = Answer.find(params[:id])
      
       respond_to do |format|
      if @answer.update(answer_params)
        #ATUALIZOU DADOS
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Atualizou a Resposta: ' + @answer.description.to_s
        log.save!  
        
        format.html { redirect_to questions_path, notice: 'Resposta atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @answer }
      else
        format.html { render :edit }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
    end

  def destroy
    @question = Question.find(params[:question_id])
    @answer = @question.answers.find(params[:id])
    @answer.destroy
    redirect_to question_path(@question)
    
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu resposta - Transporte Aéreo / Cliente ' + @answer.description.to_s
        log.save!
  end
  
  private
   
    # Never trust parameters from the scary internet, only allow the white list through.
    def answer_params
      params.require(:answer).permit(:description, :score, :question_id)
    end
end
