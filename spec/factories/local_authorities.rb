FactoryGirl.define do
  factory :local_authority do
    name "Angus Council"
    gss "S12000041"
    snac "00QC"
    tier "unitary"
    slug { name.parameterize }
    homepage_url "http://www.angus.gov.uk"
  end
end
