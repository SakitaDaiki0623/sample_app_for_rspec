FactoryBot.define do
  factory :user do
    email { "sample@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
