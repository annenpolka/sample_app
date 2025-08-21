class Api::BaseController < ActionController::API
  include ActionController::MimeResponds
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Not Found' }, status: :not_found
  end
  def create_token(user_id)
    payload = {user_id: user_id}
    secret_key = Rails.application.credentials.secret_key_base
    token = JWT.encode(payload, secret_key)
    return token
  end
end