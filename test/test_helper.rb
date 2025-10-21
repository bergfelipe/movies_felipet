ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Executa testes em paralelo
  parallelize(workers: :number_of_processors)

  # Carrega fixtures automaticamente
  fixtures :all

  # Métodos auxiliares para todos os testes
end

# ✅ Helper de login (usado em testes de controller/integration)
class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "123456"
      }
    }
  end
end
