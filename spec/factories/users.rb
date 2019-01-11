FactoryBot.define do
  factory :user do
    name { "New User" }
    email { "user@email.com" }
    permissions { %w[signin] }
  end
end
