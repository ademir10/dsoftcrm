class Category < ActiveRecord::Base
  belongs_to :quiz
  has_many :questions
  
  validates :name, uniqueness: true
  validates :name, :r1, :r2, :r3, :r4, :r5, :r6,
  presence: true
end
