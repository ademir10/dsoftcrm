class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients
  # GET /clients.json
  def index
    if params[:exportar] == 'SIM'
    @clients = Client.select('name as First_Name, cellphone as Mobile_Phone, created_at').distinct(:name).order('created_at DESC')
    else
    @clients = Client.distinct(:name).order('created_at DESC')  
    end
      
    respond_to do |format|
    format.html # don't forget if you pass html
    #format.xls { send_data(@clients.to_xls) }
    #renomeando o arquivo
    format.xls {
       filename = "Clientes-#{Time.now.strftime("%d%m%Y%H%M%S")}.xls"
       send_data(@clients.to_xls, :type => "text/xls; charset=utf-8; header=present", :filename => filename)
     }
  end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'Cliente criado com sucesso.' }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        #ATUALIZOU DADOS
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Atualizou Cliente ' + @client.name.to_s
        log.save!  
        
        format.html { redirect_to @client, notice: 'Cliente atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy
    
        #inserindo no log de atividades
        log = Loginfo.new(params[:loginfo])
        log.employee = current_user.name
        log.task = 'Excluiu Cliente ' + @client.name.to_s
        log.save!
        
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Cliente excluido com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:name, :cellphone)
    end
end
