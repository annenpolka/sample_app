require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "account_activation" do
    subject(:mail) { UserMailer.account_activation(user) }
    let(:user) { create(:user) }
    let(:from_email) { "annenpolka.lan@gmail.com" }

    before do
      user.activation_token = User.new_token
    end

    context "メールの内容が正しい" do
      it do
        expect(mail.subject).to eq("Account activation")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([from_email])
        expect(mail.body.encoded).to include(user.name)
        expect(mail.body.encoded).to include(user.activation_token)
        expect(mail.body.encoded).to include(CGI.escape(user.email))

      end
    end
  end

  describe "password_reset" do
    let(:mail) { UserMailer.password_reset }

    # it "renders the headers" do
    #   expect(mail.subject).to eq("Password reset")
    #   expect(mail.to).to eq(["to@example.org"])
    #   expect(mail.from).to eq(["from@example.com"])
    # end

    # it "renders the body" do
    #   expect(mail.body.encoded).to match("Hi")
    # end
  end

end
