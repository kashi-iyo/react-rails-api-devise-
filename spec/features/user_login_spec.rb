require 'rails_helper'

RSpec.feature "UserLogins", type: :feature do
  describe "ログイン機能" do
    let!(:user) { FactoryBot.create(:user) }
    it "ログインしたら自分のtodo itemsへリダイレクトさせること" do
      visit root_path
      click_link "Login"
      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_button "Log in"
      expect(page).to have_content("My To Do Items")
      expect(page).to have_current_path(authenticated_root_path)
    end
  end
end
