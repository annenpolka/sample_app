class Api::BaseController < ActionController::API
  include ActionController::MimeResponds
  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Not Found' }, status: :not_found
  end

  private

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    payload = decode_token(token)
    
    if payload
      @current_user_id = payload['user_id']
      @current_user = User.find(@current_user_id)
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :unauthorized
  end

  def create_token(user_id)
    payload = {user_id: user_id, exp: 24.hours.from_now.to_i }
    secret_key = Rails.application.credentials.secret_key_base
    token = JWT.encode(payload, secret_key, 'HS256')
    return token
  end

  def decode_token(token)
    decoded = JWT.decode(
      token,
      Rails.application.credentials.secret_key_base,
      true,
      {
        algorithm: 'HS256',
        verify_expiration: true  # 有効期限を自動チェック
      }
    )
    decoded[0] # payloadを返す
  rescue JWT::ExpiredSignature
    # 期限切れの場合
    nil
  rescue JWT::DecodeError
    # その他のエラー
    nil
  end
end