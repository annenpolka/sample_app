module LoginHelpers
  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする
  def log_in_as(user, remember_me: '1')
    post login_path, params: { session: { email: user.email, password: user.password, remember_me: remember_me } }
  end

end