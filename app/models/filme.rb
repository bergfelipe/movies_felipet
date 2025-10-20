class Filme < ApplicationRecord
  belongs_to :user

  has_many :comentarios, dependent: :destroy

  validates :titulo, :sinopse, :ano_lancamento, :duracao, :diretor, presence: true
  validates :ano_lancamento, numericality: { only_integer: true, greater_than: 1800 }
  validates :duracao, numericality: { only_integer: true, greater_than: 0 }
  validates :imagem_url, presence: false
end
