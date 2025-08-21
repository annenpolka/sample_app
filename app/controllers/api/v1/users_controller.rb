class Api::V1::UsersController < Api::BaseController
  def index
  end

  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def create
  end

  def update
  end

  def destroy
  end
end
