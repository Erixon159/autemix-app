FactoryBot.define do
  factory :technician do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    failed_attempts { 0 }
    locked_at { nil }
    association :tenant
    
    trait :locked do
      failed_attempts { 5 }
      locked_at { 30.minutes.ago }
    end
    
    trait :with_failed_attempts do |n = 3|
      failed_attempts { n }
    end
  end
end
