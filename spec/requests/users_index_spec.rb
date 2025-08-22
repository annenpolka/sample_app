require 'rails_helper'

RSpec.describe "UsersIndex", type: :request do
  let(:user) { create(:user) }
  let!(:users) { create_list(:user, 100)}

  describe "GET /users" do
    it "index including pagination" do
      log_in_as(user)
      get users_path
      expect(response).to render_template("users/index")
      dom = Capybara.string(response.body)
      expect(dom).to have_css('div.pagination', count: 2)
      User.paginate(page: 1).each do |user|
        expect(dom).to have_link(user.name, href: user_path(user), exact_text: true)
      end
    end
  end
end
