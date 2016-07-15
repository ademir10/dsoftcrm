class Cidade < ActiveRecord::Base
  belongs_to :estado
  has_many :clients
  has_many :suppliers
  has_many :invoices
    
end