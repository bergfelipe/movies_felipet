class ApplicationController < ActionController::Base
  # Define o layout dinamicamente
  layout :layout_by_resource

  # Configura parâmetros extras do Devise (como :name)
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Adiciona tipos de flash customizados
  add_flash_types :success, :warning

  protected

  # Escolhe o layout dependendo do tipo de controller
  def layout_by_resource
    if devise_controller?
      "devise" # usa app/views/layouts/devise.html.erb (sem navbar)
    else
      "application" # usa o layout normal (com navbar)
    end
  end

  # Libera parâmetros adicionais pro Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
