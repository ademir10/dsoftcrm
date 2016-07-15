class PagesController < ApplicationController
  #before_action :must_login
    
  def index
    @date = DateTime.now.year
    @categories = Category.order(:position)
  end
  
  #grafico anual de vendas por categoria
  def sales_report
    
    #agendamentos
      meeting_annual = Meeting.select("date_trunc( 'month', created_at ) as month, sum(cotation_value) as total_quantity").where(status: 'COMPROU').group('month').order('month')
      meeting_by_month = []
      
      meeting_annual.each do |
      meeting |
      meeting_by_month.push({
          :label => meeting.month.strftime("%B"),
          :value => meeting.total_quantity
      })
      end

      @meeting_annual = Fusioncharts::Chart.new({
          :height => '50%',
          :width => '100%',
          :type => 'column2d',
          :renderAt => 'chart-container-m',
          :dataSource => {
              :chart => {
                  :xAxisname => 'Representação gráfica por mes',
                  :yAxisName => 'Valores em (R$)',
                  :numberPrefix => 'R$',
                  :theme => 'fint',
                  :formatNumberScale=> '0',
                  :decimalSeparator=> ',',
                  :thousandSeparator=> '.',
              },
              :data => meeting_by_month
          }
      })
    
      #pacote de viagens
      pack_annual = Packsearch.select("date_trunc( 'month', created_at ) as month, sum(cotation_value) as total_quantity").where(finished: 'SIM').group('month').order('month')
      packsearch_by_month = []
      
      pack_annual.each do |
      pack |
      packsearch_by_month.push({
          :label => pack.month.strftime("%B"),
          :value => pack.total_quantity
      })
      end

      @pack_annual = Fusioncharts::Chart.new({
          :height => '50%',
          :width => '100%',
          :type => 'column2d',
          :renderAt => 'chart-container-p',
          :dataSource => {
              :chart => {
                  :xAxisname => 'Representação gráfica por mes',
                  :yAxisName => 'Valores em (R$)',
                  :numberPrefix => 'R$',
                  :theme => 'fint',
                  :formatNumberScale=> '0',
                  :decimalSeparator=> ',',
                  :thousandSeparator=> '.',
              },
              :data => packsearch_by_month
          }
      })
      
      #transporte aereo
      air_annual = Airsearch.select("date_trunc( 'month', created_at ) as month, sum(cotation_value) as total_quantity").where(finished: 'SIM').group('month').order('month')
      airsearch_by_month = []
      
      air_annual.each do |
      air |
      airsearch_by_month.push({
          :label => air.month.strftime("%B"),
          :value => air.total_quantity
      })
      end

      @air_annual = Fusioncharts::Chart.new({
          :height => '50%',
          :width => '100%',
          :type => 'column2d',
          :renderAt => 'chart-container-a',
          :dataSource => {
              :chart => {
                  :xAxisname => 'Representação gráfica por mes',
                  :yAxisName => 'Valores em (R$)',
                  :numberPrefix => 'R$',
                  :theme => 'fint',
                  :formatNumberScale=> '0',
                  :decimalSeparator=> ',',
                  :thousandSeparator=> '.',
              },
              :data => airsearch_by_month
          }
      })
    
      #transporte rodoviario
      rodo_annual = Rodosearch.select("date_trunc( 'month', created_at ) as month, sum(cotation_value) as total_quantity").where(finished: 'SIM').group('month').order('month')
      rodosearch_by_month = []
      
      rodo_annual.each do |
      rodo |
      rodosearch_by_month.push({
          :label => rodo.month.strftime("%B"),
          :value => rodo.total_quantity
      })
      end

      @rodo_annual = Fusioncharts::Chart.new({
          :height => '50%',
          :width => '100%',
          :type => 'column2d',
          :renderAt => 'chart-container-r',
          :dataSource => {
              :chart => {
                  :xAxisname => 'Representação gráfica por mes',
                  :yAxisName => 'Valores em (R$)',
                  :numberPrefix => 'R$',
                  :theme => 'fint',
                  :formatNumberScale=> '0',
                  :decimalSeparator=> ',',
                  :thousandSeparator=> '.',
              },
              :data => rodosearch_by_month
          }
      })
      
    end 
    
    #Pesquisas pendentes com status "NÃO DEFINIDO"
    def pendencies_report
      
      #SE O USUÁRIO FOR DIFERENTE DE USER
      if current_user.type_access != 'USER'
     
          @users = User.where('type_access != ?', 'MASTER').order(:name)
          if params[:date1].blank?
            params[:date1] = Date.today
          end
          
          if params[:date2].blank?
            params[:date2] = Date.today
          end
          
          #se não informar nada, é carregado somentes as vendas do dia
          if params[:seller].blank? && params[:date1].blank? && params[:date2].blank?
            @packsearch = Packsearch.where(status: 'NÃO DEFINIDO').where("updated_at::Date ?",Date.today).order(:updated_at)
            @airsearch = Airsearch.where(status: 'NÃO DEFINIDO').where("updated_at::Date ?",Date.today).order(:updated_at)
            @rodosearch = Rodosearch.where(status: 'NÃO DEFINIDO').where("updated_at::Date ?",Date.today).order(:updated_at)
          end
          
          #Se tiver informado somente as datas
          if params[:seller].blank? && params[:date1].present? && params[:date2].present?
            @packsearch = Packsearch.where(status: 'NÃO DEFINIDO').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
            @airsearch = Airsearch.where(status: 'NÃO DEFINIDO').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
            @rodosearch = Rodosearch.where(status: 'NÃO DEFINIDO').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
          end
          
          #Se tiver informado o funcionario e as datas
          if params[:seller].present? && params[:date1].present? && params[:date2].present?
            @packsearch = Packsearch.where(user: params[:seller]).where(status: 'NÃO DEFINIDO').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
            @airsearch = Airsearch.where(user: params[:seller]).where(status: 'NÃO DEFINIDO').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
            @rodosearch = Rodosearch.where(user: params[:seller]).where(status: 'NÃO DEFINIDO').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
          end
          
       else
        #se o usuário for USER
        @packsearch = Packsearch.where(user: current_user.name).where(status: 'NÃO DEFINIDO')
        @airsearch = Airsearch.where(user: current_user.name).where(status: 'NÃO DEFINIDO')
        @rodosearch = Rodosearch.where(user: current_user.name).where(status: 'NÃO DEFINIDO')
       end       
         
  end
  
  #Analise grafica de vendas por segmento de marketing
  def marketing_report
    @datainicial = params[:date1]
    @datafinal = params[:date2]
    
    if params[:date1].blank?
      params[:date1] = Date.today
    end
    
    if params[:date2].blank?
      params[:date2] = Date.today
    end
    
    #quantidade de pesquisas feitas de acordo com o periodo informado
    #se não informar nenhuma data é féito com base na data do dia
    if params[:date1].blank? || params[:date2].blank?
       @qnt_pack = Packsearch.where(finished: 'SIM').where("updated_at::Date = ?", Date.today).count
       @qnt_air = Airsearch.where(finished: 'SIM').where("updated_at::Date = ?", Date.today).count
       @qnt_rodo = Rodosearch.where(finished: 'SIM').where("updated_at::Date = ?", Date.today).count
     else
       @qnt_pack = Packsearch.where(finished: 'SIM').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).count
       @qnt_air = Airsearch.where(finished: 'SIM').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).count
       @qnt_rodo = Rodosearch.where(finished: 'SIM').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).count
    end

  end
  
  #Relatório geral de rendimento dos funcionários separado por perquisa
  def business_report
    @datainicial = params[:date1]
    @datafinal = params[:date2]
  
    if params[:date1].present? && params[:date2].present?  
    #calculando o total de pesquisas que aconteceram no periodo informado e dividindo pelas vendas efetivadas
    @total_meeting = Meeting.where("created_at::Date between ? and ?", params[:date1],params[:date2]).count
    @total_meeting_sale = Meeting.where(status: 'COMPROU').where("created_at::Date between ? and ?", params[:date1],params[:date2]).count

    @total_pack = Packsearch.where("created_at::Date between ? and ?",params[:date1],params[:date2]).count
    @total_pack_sale = Packsearch.where(finished: 'SIM').where("created_at::Date between ? and ?",params[:date1],params[:date2]).count

    @total_air = Airsearch.where("created_at::Date between ? and ?",params[:date1],params[:date2]).count
    @total_air_sale = Airsearch.where(finished: 'SIM').where("created_at::Date between ? and ?",params[:date1],params[:date2]).count

    @total_rodo = Rodosearch.where("created_at::Date between ? and ?",params[:date1],params[:date2]).count
    @total_rodo_sale = Rodosearch.where(finished: 'SIM').where("created_at::Date between ? and ?",params[:date1],params[:date2]).count
    end
    
  end
  
  #Relatório geral analitico por tipo de venda e data
  def analitics_report
    
    @users = User.where('type_access != ?', 'MASTER').order(:name)
    if params[:date1].blank?
      params[:date1] = Date.today
    end
    
    if params[:date2].blank?
      params[:date2] = Date.today
    end
    
    #se não informar nada, é carregado somentes as vendas do dia
    if params[:seller].blank? && params[:date1].blank? && params[:date2].blank?
      @meeting = Meeting.where(status: 'COMPROU').where("updated_at::Date = ?",Date.today).order(:updated_at)
      @total_meeting = Meeting.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).sum(:cotation_value)
      
      @packsearch = Packsearch.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).order(:updated_at)
      @total_packsearch = Packsearch.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).sum(:cotation_value)
      
      @airsearch = Airsearch.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).order(:updated_at)
      @total_airsearch = Airsearch.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).sum(:cotation_value)
      
      @rodosearch = Rodosearch.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).order(:updated_at)
      @total_rodosearch = Rodosearch.where(status: 'COMPROU').where("updated_at::Date ?",Date.today).sum(:cotation_value)

      
      @total_geral = @total_meeting.to_f + @total_packsearch.to_f + @total_airsearch.to_f + @total_rodosearch.to_f
      @total_geral = @total_geral.round(2)
    end
    
    #Se tiver informado somente as datas
    if params[:seller].blank? && params[:date1].present? && params[:date2].present?
      @meeting = Meeting.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_meeting = Meeting.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)
      
      @packsearch = Packsearch.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_packsearch = Packsearch.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)
      
      @airsearch = Airsearch.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_airsearch = Airsearch.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)
      
      @rodosearch = Rodosearch.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_rodosearch = Rodosearch.where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)

      
      @total_geral = @total_meeting.to_f + @total_packsearch.to_f + @total_airsearch.to_f + @total_rodosearch.to_f 
      @total_geral = @total_geral.round(2)  
    end
    
    #Se tiver informado o funcionario e as datas
    if params[:seller].present? && params[:date1].present? && params[:date2].present?
      @meeting = Meeting.where(clerk_name: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_meeting = Meeting.where(clerk_name: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)
      
      @packsearch = Packsearch.where(user: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_packsearch = Packsearch.where(user: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)
      
      @airsearch = Airsearch.where(user: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_airsearch = Airsearch.where(user: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)
      
      @rodosearch = Rodosearch.where(user: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).order(:updated_at)
      @total_rodosearch = Rodosearch.where(user: params[:seller]).where(status: 'COMPROU').where("updated_at::Date between ? and ?",params[:date1],params[:date2]).sum(:cotation_value)

      
      @total_geral = @total_meeting.to_f + @total_packsearch.to_f + @total_airsearch.to_f + @total_rodosearch.to_f
      @total_geral = @total_geral.round(2)
    end
    
  end
 
end
