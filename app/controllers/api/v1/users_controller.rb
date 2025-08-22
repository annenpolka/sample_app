class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user, only: [:index, :update, :destroy]
  def index
    @users = User.paginate(page: params[:page], per_page: 30)
                 .select(:id, :name)
    render json: {
      users: @users,
      meta: {
        current_page: @users.current_page,
        total_pages: @users.total_pages,
        total_count: @users.total_entries
      }
    }
  end

  def show
    @user = User.select(:id, :name).find(params[:id])
    render json: @user
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
