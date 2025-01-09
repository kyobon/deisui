FactoryBot.define do
    factory :user do
        name { "Example User" }
        email { "user@example.com" }
        password { "testpassword" }
        password_confirmation { "testpassword" }
        activated { true }
        activated_at { Time.zone.now }

        trait :michael do
            name { "Michael Example" }
            email { "michael@example.com" }
            password { "password" }
            password_confirmation { "password" }
        end

        trait :bob do
            name { "Bob Example" }
            email { "bob@example.com" }
            password { "password" }
            password_confirmation { "password" }
            admin { true }
        end

        trait :shige do
            name { "Shige Example" }
            email { "shige@example.com" }
            password { "password" }
            password_confirmation { "password" }
        end
    end
end