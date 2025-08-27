module ApiAuthHelpers
  # 共通のAPIヘッダ
  def api_headers
    { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
  end

  # Authorizationヘッダを付与
  def auth_headers(token)
    api_headers.merge('Authorization' => "Bearer #{token}")
  end

  # APIでのログイン（JWT取得用）
  # user でも email(String) でも指定可
  def log_in_as(user_or_email, password: 'secret123')
    email = user_or_email.is_a?(User) ? user_or_email.email : user_or_email
    post api_v1_auth_login_path,
         params: { user: { email: email, password: password } }.to_json,
         headers: api_headers
  end

  # JSONレスポンスのパース
  def response_json
    JSON.parse(response.body).with_indifferent_access
  end

  # 指定ユーザーのトークンを取得（デフォルトのパスワードはテストで使用する値に合わせる）
  def token_for(user, password: 'secret123')
    log_in_as(user, password: password)
    response_json[:user][:token]
  end
end
