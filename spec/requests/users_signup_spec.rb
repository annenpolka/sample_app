# spec/requests/users_signup_spec.rb
require "rails_helper"

RSpec.describe "Users signup", type: :request do
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

  it "valid signup information" do
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
