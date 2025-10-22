class ImportsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

 def create
  if params[:file].present?
    uploaded = params[:file]
    temp_path = Rails.root.join("tmp", "uploads", "#{SecureRandom.hex}.csv")

    FileUtils.mkdir_p(File.dirname(temp_path))
    File.open(temp_path, "wb") { |f| f.write(uploaded.read) }

    # 🚀 dispara o job, agora com caminho convertido pra string
    ImportarFilmesJob.perform_later(current_user.id, temp_path.to_s)

    redirect_to new_import_path, notice: "Importação iniciada! Você receberá um e-mail ao término."
  else
    redirect_to new_import_path, alert: "Selecione um arquivo CSV antes de enviar."
  end
end



end
