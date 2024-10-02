require "json"
require "securerandom"

class ApplicationsController < ApplicationController
  def create
    application = Application.new(application_params)
    if application.valid?
      generated_token = ApplicationsController::generate_token

      render json: { message: "Application is saved successfully and your token to use is : #{generated_token}" }, status: :created

      opts = { "name" => application.name, "token" => generated_token }
      ApplicationCreationJob.perform_async(opts.to_json)
    else
      render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    application = Application.find_by(token: params[:token])
    if application
      render json: application, status: :ok
    else
      render json: { message: "Application not found" }, status: :not_found
    end
  end

  def update
    application = Application.find_by(token: params[:token])
    if application
      if application.update(application_params)
        render json: application, status: :ok
      else
        render json: { errors: application.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "Application not found" }, status: :not_found
    end
  end

  def application_params
    params.require(:application).permit(:name)
  end

  def self.generate_token
    # making sure that the token is unique
    token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Application.exists?(token: random_token)
    end
  end
end
