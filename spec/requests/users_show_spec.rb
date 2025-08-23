require 'rails_helper'

RSpec.describe "UsersShow", type: :request do
  let(:activated_user) { create(:user) }
  let(:inactive_user) { create(:user, activated: false) }

  # before do
  #   driven_by(:rack_test)
  # end

  context "有効化されていない場合はリダイレクトする" do
    it do
      get user_path(inactive_user)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_url)
    end


  end

  context "有効化されている場合はユーザーを表示する" do
    it do
      get user_path(activated_user)
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("users/show")
    end
  end

end
