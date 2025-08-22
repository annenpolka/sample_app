require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

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

end
