class LoanReason
  include StaticAssociation

  attr_accessor :name, :active, :eligible, :notice_text

  record id: 0 do |r|
    r.name = "Replacing existing finance (original)"
    r.active = false
    r.eligible = false
  end

  record id: 1 do |r|
    r.name = "Buying a business"
    r.active = false
    r.eligible = false
  end

  record id: 2 do |r|
    r.name = "Buying a business overseas"
    r.active = false
    r.eligible = false
  end

  record id: 3 do |r|
    r.name = "Developing a project"
    r.active = false
    r.eligible = false
  end

  record id: 4 do |r|
    r.name = "Expanding an existing business"
    r.active = false
    r.eligible = false
  end

  record id: 5 do |r|
    r.name = "Expanding a UK business abroad"
    r.active = false
    r.eligible = false
  end

  record id: 6 do |r|
    r.name = "Export"
    r.active = false
    r.eligible = false
  end

  record id: 7 do |r|
    r.name = "Improving vessels (health and safety)"
    r.active = false
    r.eligible = false
  end

  record id: 8 do |r|
    r.name = "Increasing size and power of vessels"
    r.active = false
    r.eligible = false
  end

  record id: 9 do |r|
    r.name = "Improving vessels (refrigeration)"
    r.active = false
    r.eligible = false
  end

  record id: 10 do |r|
    r.name = "Improving efficiency"
    r.active = false
    r.eligible = false
  end

  record id: 11 do |r|
    r.name = "Agricultural holdings investments"
    r.active = false
    r.eligible = false
  end

  record id: 12 do |r|
    r.name = "Boat modernisation (over 5 years)"
    r.active = false
    r.eligible = false
  end

  record id: 13 do |r|
    r.name = "Production processing and marketing"
    r.active = false
    r.eligible = false
  end

  record id: 14 do |r|
    r.name = "Property purchase/lease"
    r.active = false
    r.eligible = false
  end

  record id: 15 do |r|
    r.name = "Agricultural holdings purchase"
    r.active = false
    r.eligible = false
  end

  record id: 16 do |r|
    r.name = "Animal purchase"
    r.active = false
    r.eligible = false
  end

  record id: 17 do |r|
    r.name = "Equipment purchase"
    r.active = false
    r.eligible = false
  end

  record id: 18 do |r|
    r.name = "Purchasing fishing gear"
    r.active = false
    r.eligible = false
  end

  record id: 19 do |r|
    r.name = "Purchasing fishing licences"
    r.active = false
    r.eligible = false
  end

  record id: 20 do |r|
    r.name = "Purchasing fishing quotas"
    r.active = false
    r.eligible = false
  end

  record id: 21 do |r|
    r.name = "Purchasing fishing rights"
    r.active = false
    r.eligible = false
  end

  record id: 22 do |r|
    r.name = "Land purchase"
    r.active = false
    r.eligible = false
  end

  record id: 23 do |r|
    r.name = "Purchasing quotas"
    r.active = false
    r.eligible = false
  end

  record id: 24 do |r|
    r.name = "Vessel purchase"
    r.active = false
    r.eligible = false
  end

  record id: 25 do |r|
    r.name = "Research and development"
    r.active = false
    r.eligible = false
  end

  record id: 26 do |r|
    r.name = "Starting-up trading"
    r.active = false
    r.eligible = false
  end

  record id: 27 do |r|
    r.name = "Working capital"
    r.active = false
    r.eligible = false
  end

  record id: 28 do |r|
    r.name = "Start-up costs"
    r.active = true
    r.eligible = true
  end

  record id: 29 do |r|
    r.name = "General working capital requirements"
    r.active = true
    r.eligible = true
  end

  record id: 30 do |r|
    r.name = "Purchasing specific equipment or machinery"
    r.active = true
    r.eligible = true
  end

  record id: 31 do |r|
    r.name = "Purchasing licences quotas or other entitlements to trade"
    r.active = true
    r.eligible = true
  end

  record id: 32 do |r|
    r.name = "Research and Development activities"
    r.active = true
    r.eligible = true
  end

  record id: 33 do |r|
    r.name = "Acquiring another business within UK"
    r.active = true
    r.eligible = true
  end

  record id: 34 do |r|
    r.name = "Acquiring another business outside UK"
    r.active = true
    r.eligible = false
  end

  record id: 35 do |r|
    r.name = "Expanding an existing business within UK"
    r.active = true
    r.eligible = true
  end

  record id: 36 do |r|
    r.name = "Expanding an existing business outside UK"
    r.active = true
    r.eligible = false
  end

  record id: 37 do |r|
    r.name = "Replacing existing finance"
    r.active = true
    r.eligible = false
    r.notice_text = "This reason is not eligible. Please choose the original
                     purpose of the funding being refinanced."
  end

  record id: 38 do |r|
    r.name = "Financing an export order"
    r.active = true
    r.eligible = false
  end

  def self.active
    all.select(&:active)
  end

  def eligible?
    eligible
  end
end
