class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user, only: [:show, :update, :destroy]
  def index
  end

  def show
    render json: @current_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: {user: {name: @user.name, email: @user.email}}
    else
      render json: {errors: {body: @user.errors}}, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

end
