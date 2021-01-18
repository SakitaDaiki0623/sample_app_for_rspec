FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "test#{n} title" }
    content { "example content" }
    status { "todo" }
    deadline { 1.week.from_now }
    association :user, factory: :user
  end
end
