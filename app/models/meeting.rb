class Meeting < ActiveRecord::Base
  
  validates :client, :phone, :start_time, :status, :type_client, presence: true
end
