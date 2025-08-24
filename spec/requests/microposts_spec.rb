require 'rails_helper'

RSpec.describe "Microposts", type: :request do
  let!(:micropost) { create(:micropost) }
  describe "/micropost" do
    context "ログアウト時のマイクロポストの操作" do
      it "should redirect create when not logged in" do
        expect { post microposts_path }.not_to change(Micropost, :count)
        expect(response).to redirect_to(login_url)
      end

      it "should redirect destroy when not logged in" do
        expect { delete micropost_path(micropost) }.not_to change(Micropost, :count)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(login_url)
      end
    end
  end

  context "異なるユーザーのマイクロポストの操作" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:micropost) { create(:micropost, user: other_user) }
    it "should redirect destroy for wrong micropost" do
      log_in_as(user)
      expect { delete micropost_path(micropost) }.not_to change(Micropost, :count)
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_url)
    end
  end
end
