require 'rails_helper'

RSpec.describe "UsersIndex", type: :request do
  let(:user) { create(:user) }
  let!(:users) { create_list(:user, 100)}
  let(:admin) {create(:user, admin: true)}
  let!(:non_admin) {create(:user, admin: false)}

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
    it "index as admin including pagination and delete links" do
      log_in_as(admin)
      get users_path
      expect(response).to render_template("users/index")
      dom = Capybara.string(response.body)
      expect(dom).to have_css('div.pagination', count: 2)
      first_page_of_users = User.paginate(page: 1)
      first_page_of_users.each do |user|
        expect(dom).to have_link(user.name, href: user_path(user), exact_text: true)
        unless user == @admin
          expect(dom).to have_link('delete', href: user_path(user), exact_text: true)
        end
      end
      expect {
        delete user_path(non_admin)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(users_url)
      }.to change(User, :count).by(-1)
    end
    it "index as non-admin" do
      log_in_as(non_admin)
      get users_path
      dom = Capybara.string(response.body)
      expect(dom).to have_no_link('delete', href: user_path(user), exact_text: true)
    end
  end
end
