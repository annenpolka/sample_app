class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user, only: [:index, :update, :destroy, :follow, :unfollow]
  # /api/v1/me 経由のアクセスでは認証とID解決を行う
  before_action :authenticate_me!, only: [:show, :update, :following, :followers]
  before_action :assign_me_id,     only: [:show, :update, :following, :followers]
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
    @user = User.find(params[:id])

    # 管理者は任意のユーザーを更新可能。一般ユーザーは自分自身のみ許可。
    permitted = user_params
    unless @current_user.admin? || @user.id == @current_user.id
      return render json: { error: 'Forbidden' }, status: :forbidden
    end

    if @user.update(permitted)
      render json: { user: { name: @user.name, email: @user.email } }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @current_user.admin? && @current_user != @user
      @user.destroy
      render json: { destroyed: @user.destroyed? }, status: :ok
    else
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end

  def following
    @user = User.find(params[:id])
    @following = @user.following.select(:id, :name).paginate(page: params[:page])
    render json: {
      following: @following,
      meta: {
        current_page: @following.current_page,
        total_pages: @following.total_pages,
        total_count: @following.total_entries
      }
    }, status: :ok
  end

  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.select(:id, :name).paginate(page: params[:page])
    render json: {
      followers: @followers,
      meta: {
        current_page: @followers.current_page,
        total_pages: @followers.total_pages,
        total_count: @followers.total_entries
      }
    }, status: :ok
  end

  def follow
    @user = User.find(params[:id])
    if @current_user.following?(@user) || @current_user.follow(@user)
      render json: { following: @user.slice(:id, :name) }, status: :ok
    else
      render json: { error: 'Unable to follow user' }, status: :unprocessable_entity
    end
  end

  def unfollow
    @user = User.find(params[:id])
    if @current_user.unfollow(@user)
      render json: { unfollowed: @user.slice(:id, :name) }, status: :ok
    else
      render json: { error: 'Unable to unfollow user' }, status: :unprocessable_entity
    end
  end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password)
    end

    # /api/v1/me のときだけ認証を強制
    def authenticate_me!
      return unless me_endpoint?
      authenticate_user
    end

    # /api/v1/me のときは現在のユーザーIDを使用
    def assign_me_id
      return unless me_endpoint?
      return unless @current_user
      params[:id] = @current_user.id
    end

    def me_endpoint?
      # /api/v1/me およびそのサブパス（/following, /followers）を対象にする
      request.path.start_with?('/api/v1/me')
    end

end
