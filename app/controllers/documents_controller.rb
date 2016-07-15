class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :must_login
  
  # para exibir a imagem
  def show_file
  @document = Document.find(params[:id])
  end

  # GET /documents
  # GET /documents.json
  def index
    
    if params[:request] == 'airsearches'
    @data_client = Airsearch.find(params[:id])  
    @documents = Document.where(owner: @data_client.id).where(type_research: params[:request]).order(:created_at)
    #pra guardar o tipo de pesquisa na hora de pedir um novo anexo
    @type_research = 'airsearches'
    end
    
    if params[:request] == 'meetings'
    @data_client = Meeting.find(params[:id])  
    @documents = Document.where(owner: @data_client.id).where(type_research: params[:request]).order(:created_at)
    #pra guardar o tipo de pesquisa na hora de pedir um novo anexo
    @type_research = 'meetings'
    end
    
    if params[:request] == 'rodosearches'
    @data_client = Rodosearch.find(params[:id])  
    @documents = Document.where(owner: @data_client.id).where(type_research: params[:request]).order(:created_at)
    #pra guardar o tipo de pesquisa na hora de pedir um novo anexo
    @type_research = 'rodosearches'
    end
    
    if params[:request] == 'packsearches'
    @data_client = Packsearch.find(params[:id])  
    @documents = Document.where(owner: @data_client.id).where(type_research: params[:request]).order(:created_at)
    #pra guardar o tipo de pesquisa na hora de pedir um novo anexo
    @type_research = 'packsearches'
    end
    
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    send_data(@document.file_contents,
              type: @document.content_type,
              filename: @document.filename)
  end

  # GET /documents/new
  def new
    if params[:request] == 'airsearches'
      @research = Airsearch.find_by_id(params[:id])
      @type_research = 'airsearches'
    end
        if params[:request] == 'meetings'
      @research = Meeting.find_by_id(params[:id])
      @type_research = 'meetings'
    end
    
    if params[:request] == 'rodosearches'
      @research = Rodosearch.find_by_id(params[:id])
      @type_research = 'rodosearches'
    end
    
    if params[:request] == 'packsearches'
      @research = Packsearch.find_by_id(params[:id])
      @type_research = 'packsearches'
    end
    
    @document = Document.new
    
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    
    if document_params[:file].blank?
        if @document.type_research == 'airsearches'
        flash[:warning] = 'selecione o arquivo desejado!'
        @airsearch = document_params[:owner]  
        redirect_to airsearch_path(@airsearch) and return
        end
        #se for um anexo vindo de um agendamento simples
        if @document.type_research == 'meetings'
        flash[:warning] = 'selecione o arquivo desejado!'
        @meeting = document_params[:owner]  
        redirect_to meeting_path(@meeting) and return
        end
        #se for um anexo de pesquisa de transportes rodoviarios
        if @document.type_research == 'rodosearches'
        flash[:warning] = 'selecione o arquivo desejado!'
        @rodosearch = document_params[:owner]  
        redirect_to rodosearch_path(@rodosearch) and return
        end
        #se for um anexo de pesquisa de transportes rodoviarios
        if @document.type_research == 'packsearches'
        flash[:warning] = 'selecione o arquivo desejado!'
        @packsearch = document_params[:owner]  
        redirect_to packsearch_path(@packsearch) and return
        end

    end

    respond_to do |format|
      
      if @document.save
      
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Efetuou upload de anexo para pesquisa do tipo ' + @document.type_research.to_s
        log.save!  
        
        #se for um anexo de pesquisa de transportes aéreos
        if @document.type_research == 'airsearches'
        @airsearch = document_params[:owner]
        format.html { redirect_to airsearch_path(@airsearch), notice: 'Arquivo salvo com sucesso.' }
        end
        #se for um anexo vindo de um agendamento simples
        if @document.type_research == 'meetings'
        @meeting = document_params[:owner]
        format.html { redirect_to meeting_path(@meeting), notice: 'Arquivo salvo com sucesso.' }
        end
        #se for um anexo de pesquisa de transportes rodoviarios
        if @document.type_research == 'rodosearches'
        @rodosearch = document_params[:owner]
        format.html { redirect_to rodosearch_path(@rodosearch), notice: 'Arquivo salvo com sucesso.' }
        end
        #se for um anexo de pesquisa de transportes rodoviarios
        if @document.type_research == 'packsearches'
        @packsearch = document_params[:owner]
        format.html { redirect_to packsearch_path(@packsearch), notice: 'Arquivo salvo com sucesso.' }
        end
        
        
        format.json { render action: 'show', status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu anexo / arquivo ' + @document.file.to_s + 'referente a pesquisa tipo ' + @document.type_research.to_s
        log.save
    
    respond_to do |format|
      format.html { redirect_to meetings_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:file, :owner, :type_research)
    end
end