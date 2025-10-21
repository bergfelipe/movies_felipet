class Tag < ApplicationRecord
  has_and_belongs_to_many :filmes
  validates :nome, presence: true, uniqueness: true
end
