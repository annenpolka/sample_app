require 'rails_helper'

RSpec.describe "Users Login", type: :request do
  before(:each) do
    @user = create(:john)
  end

  describe "/login" do
    it "login with valid information" do
      post login_path, params: { session: { email:    @user.email,
                                            password: @user.password } }
      expect(response).to be_redirect
      expect(response).to redirect_to(user_path(User.last))
      follow_redirect!
      expect(response).to render_template("users/show")
      dom = Capybara.string(response.body)
      expect(dom).to have_no_link(href: login_path)
      expect(dom).to have_link(href: logout_path)
      expect(dom).to have_link(href: user_path(@user))
    end

    it "login with invalid information" do
      get login_path
      expect(response).to render_template("sessions/new")
      post login_path, params: { session: { email: "", password: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template("sessions/new")
      expect(flash).not_to be_empty
      get root_path
      expect(flash).to be_empty
    end

    it "login with valid email/invalid password" do
      get login_path
      expect(response).to render_template("sessions/new")
      post login_path, params: { session: { email: @user.email, password: "invalid" } }
      expect(is_logged_in?).not_to be_truthy
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template("sessions/new")
      expect(flash).not_to be_empty
      get root_path
      expect(flash).to be_empty
    end

    it "login with valid information followed by logout" do
      post login_path, params: { session: { email:    @user.email,
                                            password: @user.password } }
      expect(is_logged_in?).to be_truthy
      expect(response).to redirect_to(user_path(User.last))
      follow_redirect!
      expect(response).to render_template("users/show")
      login_dom = Capybara.string(response.body)
      expect(login_dom).to have_no_link(href: login_path)
      expect(login_dom).to have_link(href: logout_path)
      expect(login_dom).to have_link(href: user_path(@user))
      delete logout_path
      expect(is_logged_in?).not_to be_truthy
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_url)
      follow_redirect!
      logout_dom = Capybara.string(response.body)
      expect(logout_dom).to have_link(href: login_path)
      expect(logout_dom).to have_no_link(href: logout_path)
      expect(logout_dom).to have_no_link(href: user_path(@user))

    end

  end
end
