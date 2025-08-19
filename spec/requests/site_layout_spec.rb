# spec/requests/site_layout_spec.rb
require "rails_helper"

RSpec.describe "Site layout", type: :request do
  it "layout links" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response).to render_template("static_pages/home")

    dom = Capybara.string(response.body)
    aggregate_failures do
      expect(dom).to have_css(%(a[href="#{root_path}"]), count: 2)
      expect(dom).to have_css(%(a[href="#{help_path}"]))
      expect(dom).to have_css(%(a[href="#{about_path}"]))
      expect(dom).to have_css(%(a[href="#{contact_path}"]))
      get contact_path
      contact_dom = Capybara.string(response.body)
      expect(contact_dom).to have_title(ApplicationController.helpers.full_title('Contact'), exact: true)

    end
  end
end
