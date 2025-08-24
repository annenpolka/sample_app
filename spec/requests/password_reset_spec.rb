# spec/requests/users_signup_spec.rb
require "rails_helper"

RSpec.describe "Password Reset", type: :request do
  let(:user) { create(:user) }
  before do
    ActionMailer::Base.deliveries.clear
  end

  context "パスワードを忘れた画面の操作" do
    it "password reset path" do
      get new_password_reset_path
      expect(response).to render_template("password_resets/new")
      dom = Capybara.string(response.body)
      expect(dom).to have_field(name: 'password_reset[email]')
   end

   it "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(flash).not_to be_empty
    expect(response).to render_template("password_resets/new")
    end
  end

  context "パスワードリセット画面の操作" do
    before do
      post password_resets_path,
           params: { password_reset: { email: user.email } }
      @reset_user = assigns(:user)
    end

    it "reset with valid email" do
      expect(user.reset_digest).not_to eq(@reset_user.reset_digest)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(flash).not_to be_empty
      expect(response).to redirect_to(root_url)
    end

    it "reset with wrong email" do
        get edit_password_reset_path(@reset_user.reset_token, email: "")
        expect(response).to redirect_to(root_url)
    end

    it "reset with inactive user" do
      @reset_user.toggle!(:activated)
      get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
      expect(response).to redirect_to(root_url)
    end

    it "reset with right email but wrong token" do
      get edit_password_reset_path('wrong token', email: @reset_user.email)
      assert_redirected_to root_url
    end

    it "reset with right email and right token" do
      get edit_password_reset_path(@reset_user.reset_token,
                                   email: @reset_user.email)
      assert_template 'password_resets/edit'
      expect(response).to render_template("password_resets/edit")
      dom = Capybara.string(response.body)
      expect(dom).to have_field('email', type: 'hidden', with: @reset_user.email)
    end
  end

  context "パスワード更新時の操作" do
    before do
      post password_resets_path,
           params: { password_reset: { email: user.email } }
      @reset_user = assigns(:user)
    end

    it "update with invalid password and confirmation" do
      patch password_reset_path(@reset_user.reset_token),
            params: { email: @reset_user.email,
                      user: { password:              "foobaz",
                              password_confirmation: "barquux" } }
      dom = Capybara.string(response.body)
      expect(dom).to have_css("div#error_explanation")
    end

    it "update with empty password" do
      patch password_reset_path(@reset_user.reset_token),
            params: { email: @reset_user.email,
                      user: { password:              "",
                              password_confirmation: "" } }
      dom = Capybara.string(response.body)
      expect(dom).to have_css("div#error_explanation")
    end

    it "update with valid password and confirmation" do
      patch password_reset_path(@reset_user.reset_token),
            params: { email: @reset_user.email,
                      user: { password:              "foobaz",
                              password_confirmation: "foobaz" } }
      expect(is_logged_in?).to be_truthy
      expect(flash).not_to be_empty
      expect(response).to redirect_to(@reset_user)
      expect(@reset_user.reload.reset_digest).to be_nil
    end
  end

  context "トークン失効時" do
    before do
      post password_resets_path,
           params: { password_reset: { email: user.email } }
      @reset_user = assigns(:user)
      # トークンを手動で失効させる
      @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
      # ユーザーのパスワードの更新を試みる
      patch password_reset_path(@reset_user.reset_token),
            params: { email: @reset_user.email,
                      user: { password:              "foobar",
                              password_confirmation: "foobar" } }
    end

    it "should redirect to the password-reset page" do
      expect(response).to redirect_to(new_password_reset_url)
    end
    it "should include the word 'expired' on the password-reset page" do
      follow_redirect!
      expect(response.body).to match(/expire/i)
    end
  end
end