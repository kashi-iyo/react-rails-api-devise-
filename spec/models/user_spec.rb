require 'rails_helper'

RSpec.describe User, type: :model do

  describe "登録" do
    let!(:user) { FactoryBot.create(:user) }

    it "登録可能であること" do
      expect(user).to be_valid
    end
  end

  describe "バリデーション" do
    let(:user) { FactoryBot.build(:user) }
    let(:duplicate_user) { FactoryBot.build(:user) }

    it "ユニークなアドレスでなければならないこと" do
      user.save!
      duplicate_user.email = user.email
      expect(duplicate_user).to_not be_valid
    end

    it "パスワードを持たなければならないこと" do
      user.password = nil
      expect(user).to_not be_valid
    end
  end

  describe "todo itemとのアソシエーション" do
    let!(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }

    it "複数のtodo itemsを持っていること" do
      relation = described_class.reflect_on_association(:todo_items)
      expect(relation.macro).to eq(:has_many)
    end

    it "関連付けされたtodo itemsを削除すること" do
      expect{ user_with_todo_items.destroy }.to change { TodoItem.count }.by(-5)
    end
  end


end
