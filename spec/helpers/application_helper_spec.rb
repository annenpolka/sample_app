require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#full_title' do
    it '空ならベースタイトルを返す' do
      expect(helper.full_title).to eq 'Ruby on Rails Tutorial Sample App'
    end

    it 'ページタイトルを連結する' do
      expect(helper.full_title('Help')).to eq 'Help | Ruby on Rails Tutorial Sample App'
    end
  end
end