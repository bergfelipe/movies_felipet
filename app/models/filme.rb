class Filme < ApplicationRecord
  belongs_to :user
  has_many :comentarios, dependent: :destroy
  has_and_belongs_to_many :categorias
  validates :titulo, :sinopse, :ano_lancamento, :duracao, :diretor, presence: true
  validates :ano_lancamento, numericality: { only_integer: true, greater_than: 1800 }
  validates :duracao, numericality: { only_integer: true, greater_than: 0 }
  validates :imagem_url, presence: false
  has_and_belongs_to_many :tags
  has_one_attached :poster
  attr_accessor :tag_list
  attr_accessor :importing_csv

  def self.ransackable_attributes(_auth_object = nil)
    %w[id titulo diretor ano_lancamento duracao sinopse imagem_url created_at updated_at user_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[categorias user comentarios]
  end

  def importing_csv?
  importing_csv == true
  end

  
end
