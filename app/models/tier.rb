class Tier
  COUNTY = 1
  DISTRICT = 2
  UNITARY = 3

  def self.county
    COUNTY
  end

  def self.district
    DISTRICT
  end

  def self.unitary
    UNITARY
  end

  def self.as_string(tier)
    case tier
    when COUNTY
      "county"
    when DISTRICT
      "district"
    when UNITARY
      "unitary"
    end
  end
end
