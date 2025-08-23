# spec/requests/users_signup_spec.rb
require "rails_helper"

RSpec.describe "Users signup", type: :request do
  before do
    ActionMailer::Base.deliveries.clear
  end

  context "ユーザー登録画面の操作" do
    it "invalid signup information" do
      get signup_path

      expect {
        post users_path, params: {
          user: {
            name: "",
            email: "user@invalid",
            password: "foo",
            password_confirmation: "bar"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template("users/new")
      dom = Capybara.string(response.body)
      expect(dom).to have_css('div#error_explanation')
      expect(dom).to have_css('div.field_with_errors')
    end

    it "valid signup information with account activation" do
      expect {
        post users_path, params: {
          user: {
            name: "Example User",
            email: "user@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      }.to change(User, :count).by(1)
      expect(response).to be_redirect
      follow_redirect!
      # expect(response).to render_template("users/show")
      expect(flash).not_to be_empty
      # expect(is_logged_in?).to be_truthy
    end
  end

  context "アカウントの有効化" do
    before do
      post users_path, params: {
        user: {
          name: "Example User",
          email: "user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
      @user = assigns(:user)
    end

    it "有効化されていない" do
      expect(@user).not_to be_activated
    end

    it "アカウント有効化前にはログインできない" do
      expect(is_logged_in?).not_to be_truthy
    end

    it "無効な有効化トークンではログインできない" do
      get edit_account_activation_path("invalid token", email: @user.email)
      expect(is_logged_in?).not_to be_truthy
    end

    it "異なるメールアドレスではログインできない" do
      get edit_account_activation_path(@user.activation_token, email: "wrong")
      expect(is_logged_in?).not_to be_truthy
    end

    it "正しいメールアドレスと有効化トークンでログインできる" do
      get edit_account_activation_path(@user.activation_token, email: @user.email)
      expect(@user.reload).to be_activated
      follow_redirect!
      expect(response).to render_template("users/show")
      expect(is_logged_in?).to be_truthy

    end
  end

end
