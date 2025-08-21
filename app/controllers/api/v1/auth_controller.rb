class Api::V1::AuthController < Api::BaseController
  def login
    @user = User.find_by(email: params[:user][:email])
    if @user&.authenticate(params[:user][:password])
      token = create_token(@user.id)
      render json: {user: {email: @user.email, name: @user.name, token: token}}
    else
      render json: {errors: {body: @user.errors}}, status: :unauthorized
      # render status: :unauthorized
    end
  end
end
