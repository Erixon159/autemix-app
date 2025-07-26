FactoryBot.define do
  factory :vending_machine do
    name { Faker::Commerce.product_name }
    location { Faker::Address.full_address }
    api_key_digest { Rails.application.message_verifier('api_keys').generate(SecureRandom.hex(32)) }
    association :tenant
  end
end
