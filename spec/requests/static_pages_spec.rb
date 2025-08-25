require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  before(:all) do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  describe "GET /home" do
    before do
      get root_path
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      dom = Capybara.string(response.body)
      expect(dom).to have_title("#{@base_title}", exact: true)
    end
  end

  describe "GET /help" do
    it "returns http success" do
      get help_path
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  help_path
      dom = Capybara.string(response.body)
      expect(dom).to have_title("Help | #{@base_title}", exact: true)
    end
  end

  describe "GET /about" do
    it "returns http success" do
      get about_path
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  about_path
      dom = Capybara.string(response.body)
      expect(dom).to have_title("About | #{@base_title}", exact: true)
    end
  end

  describe "GET /contact" do
    it "returns http success" do
      get contact_path
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  contact_path
      dom = Capybara.string(response.body)
      expect(dom).to have_title("Contact | #{@base_title}", exact: true)
    end
  end
end
