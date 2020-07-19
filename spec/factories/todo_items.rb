FactoryBot.define do
  factory :todo_item do
    sequence(:title) { |n| "課題 #{n}" }
    user
    complete { false }

    factory :completed_todo_item do
      complete { true }
    end
  end
end
