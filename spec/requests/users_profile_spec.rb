# spec/requests/users_profile_spec.rb
require "rails_helper"

RSpec.describe "User profile", type: :request do
  include ApplicationHelper

  let!(:user)  { create(:user) }
  let!(:posts) { create_list(:micropost, 35, user: user) }


  context "profile display" do
    it do
      get user_path(user)

      aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("users/show")

        dom = Capybara.string(response.body)
        expect(dom).to have_css("title", text: full_title(user.name), visible: :all)
        expect(dom).to have_css("h1", text: user.name)
        expect(dom).to have_css("h1 > img.gravatar")

        expect(response.body).to include(user.microposts.count.to_s)
        expect(dom).to have_css("div.pagination", count: 1)

        user.microposts.paginate(page: 1).each do |micropost|
          expect(response.body).to include(micropost.content)
        end
      end
    end
  end
end
