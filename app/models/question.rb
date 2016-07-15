class Question < ActiveRecord::Base
  belongs_to :category
    
  # para poder permitir a exclusão da invoice mesmo tendo itens ou não
  has_many :answers, dependent: :destroy
  
  validates :category_id, :description, presence: true
  
end
