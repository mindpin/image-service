# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "user#{n}"}
    sequence(:email){|n| "example#{n}@example.com"}
    password 'changeme'
  end
end
