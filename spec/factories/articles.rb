FactoryBot.define do
  factory :article do
    sequence(:title) { |t| "MyString #{t}" }
    sequence(:content) { |c| "MyText #{c}" }
    sequence(:slug) { |s| "MyString #{s}" }
  end
end
