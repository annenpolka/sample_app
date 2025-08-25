require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) { create(:user, admin: true) }
  let!(:other_user) { create(:user) }

  describe "ログアウト時のリダイレクト" do
    it "should redirect edit when not logged in" do
      get edit_user_path(user)
      expect(flash).not_to be_empty
      expect(response).to redirect_to(login_url)
    end

    it "should redirect update when not logged in" do
      patch user_path(user), params: { user: { name:  user.name,
                                         email: user.email } }
      expect(flash).not_to be_empty
      expect(response).to redirect_to(login_url)
    end

    it "should redirect index when not logged in" do
      get users_path
      expect(response).to redirect_to(login_url)
    end
  end

  describe "ユーザーが異なる場合のリダイレクト" do
    it "should redirect edit when logged in as wrong user" do
      log_in_as(other_user)
      get edit_user_path(user)
      expect(flash).to be_empty
      expect(response).to redirect_to(root_url)
    end

    it "should redirect update when logged in as wrong user" do
      log_in_as(other_user)
      patch user_path(user), params: { user: { name:  user.name,
                                         email: user.email } }
      expect(flash).to be_empty
      expect(response).to redirect_to(root_url)
    end
  end

  describe "管理者権限" do
    it "should not allow the admin attribute to be edited via the web" do
      log_in_as(other_user)
      expect(other_user.admin?).not_to be_truthy
      patch user_path(other_user), params: { user: { password:  "password",
                                                     password_confirmation: "password",
                                                     admin: true } }
      expect(other_user.admin?).not_to be_truthy
    end

    it "should redirect destory when not logged in" do
      expect { delete user_path(user) }.not_to change(User, :count)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(login_url)
    end

    it "should redirect destory when logged in as a non-admin" do
      log_in_as(other_user)
      expect { delete user_path(user) }.not_to change(User, :count)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_url)
    end
  end

  describe "フォロー・フォロワー表示" do
    it "should redirect following when not logged in" do
      get following_user_path(user)
      expect(response).to redirect_to(login_url)
    end

    it "should redirect followers when not logged in" do
      get followers_user_path(user)
      expect(response).to redirect_to(login_url)
    end
  end

end
