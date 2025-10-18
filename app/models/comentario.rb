class Comentario < ApplicationRecord
  belongs_to :filme
  belongs_to :user, optional: true

  validates :conteudo, presence: true
  validate :nome_presente_se_anonimo

  default_scope { order(created_at: :desc) } # mais recente primeiro

  private

  def nome_presente_se_anonimo
    if user.nil? && nome.to_s.strip.blank?
      errors.add(:nome, "não pode ficar em branco para comentários anônimos")
    end
  end
end
