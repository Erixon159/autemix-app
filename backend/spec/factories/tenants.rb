FactoryBot.define do
  factory :tenant do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:subdomain) { |n| "company#{n}" }
    active { true }
    
    trait :inactive do
      active { false }
    end
    
    trait :with_reserved_subdomain do
      subdomain { "admin" }
    end
  end
end
