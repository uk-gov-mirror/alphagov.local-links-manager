FactoryBot.define do
  factory :user do
    name "New User"
    email "user@email.com"
    permissions { ["signin"] }
  end
end
