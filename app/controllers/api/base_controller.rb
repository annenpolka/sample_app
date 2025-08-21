class Api::BaseController < ActionController::API
  include ActionController::MimeResponds
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Not Found' }, status: :not_found
  end
end