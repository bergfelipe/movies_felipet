class Categoria < ApplicationRecord
    has_and_belongs_to_many :filmes
  
    validates :nome, presence: true, uniqueness: true
  
    # >>> Ransack allowlist <<<
    def self.ransackable_attributes(_auth_object = nil)
      %w[id nome created_at updated_at]
    end
  
    def self.ransackable_associations(_auth_object = nil)
      %w[filmes]
    end
  end
  