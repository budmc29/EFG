class LoanReason < StaticAssociation
  self.data = [
    {
      id: 0,
      name: "Replacing existing finance (original)",
      active: false,
      eligible: false,
    },
    {
      id: 1,
      name: "Buying a business",
      active: false,
      eligible: false,
    },
    {
      id: 2,
      name: "Buying a business overseas",
      active: false,
      eligible: false,
    },
    {
      id: 3,
      name: "Developing a project",
      active: false,
      eligible: false,
    },
    {
      id: 4,
      name: "Expanding an existing business",
      active: false,
      eligible: false,
    },
    {
      id: 5,
      name: "Expanding a UK business abroad",
      active: false,
      eligible: false,
    },
    {
      id: 6,
      name: "Export",
      active: false,
      eligible: false,
    },
    {
      id: 7,
      name: "Improving vessels (health and safety)",
      active: false,
      eligible: false,
    },
    {
      id: 8,
      name: "Increasing size and power of vessels",
      active: false,
      eligible: false,
    },
    {
      id: 9,
      name: "Improving vessels (refrigeration)",
      active: false,
      eligible: false,
    },
    {
      id: 10,
      name: "Improving efficiency",
      active: false,
      eligible: false,
    },
    {
      id: 11,
      name: "Agricultural holdings investments",
      active: false,
      eligible: false,
    },
    {
      id: 12,
      name: "Boat modernisation (over 5 years)",
      active: false,
      eligible: false,
    },
    {
      id: 13,
      name: "Production, processing and marketing",
      active: false,
      eligible: false,
    },
    {
      id: 14,
      name: "Property purchase/lease",
      active: false,
      eligible: false,
    },
    {
      id: 15,
      name: "Agricultural holdings purchase",
      active: false,
      eligible: false,
    },
    {
      id: 16,
      name: "Animal purchase",
      active: false,
      eligible: false,
    },
    {
      id: 17,
      name: "Equipment purchase",
      active: false,
      eligible: false,
    },
    {
      id: 18,
      name: "Purchasing fishing gear",
      active: false,
      eligible: false,
    },
    {
      id: 19,
      name: "Purchasing fishing licences",
      active: false,
      eligible: false,
    },
    {
      id: 20,
      name: "Purchasing fishing quotas",
      active: false,
      eligible: false,
    },
    {
      id: 21,
      name: "Purchasing fishing rights",
      active: false,
      eligible: false,
    },
    {
      id: 22,
      name: "Land purchase",
      active: false,
      eligible: false,
    },
    {
      id: 23,
      name: "Purchasing quotas",
      active: false,
      eligible: false,
    },
    {
      id: 24,
      name: "Vessel purchase",
      active: false,
      eligible: false,
    },
    {
      id: 25,
      name: "Research and development",
      active: false,
      eligible: false,
    },
    {
      id: 26,
      name: "Starting-up trading",
      active: false,
      eligible: false,
    },
    {
      id: 27,
      name: "Working capital",
      active: false,
      eligible: false,
    },
    {
      id: 28,
      name: 'Start-up costs',
      active: true,
      eligible: true,
    },
    {
      id: 29,
      name: 'General working capital requirements',
      active: true,
      eligible: true,
    },
    {
      id: 30,
      name: 'Purchasing specific equipment or machinery',
      active: true,
      eligible: true,
    },
    {
      id: 31,
      name: 'Purchasing licences, quotas or other entitlements to trade',
      active: true,
      eligible: true,
    },
    {
      id: 32,
      name: 'Research and Development activities',
      active: true,
      eligible: true,
    },
    {
      id: 33,
      name: 'Acquiring another business within UK',
      active: true,
      eligible: true,
    },
    {
      id: 34,
      name: 'Acquiring another business outside UK',
      active: true,
      eligible: false,
    },
    {
      id: 35,
      name: 'Expanding an existing business within UK',
      active: true,
      eligible: true,
    },
    {
      id: 36,
      name: 'Expanding an existing business outside UK',
      active: true,
      eligible: false,
    },
    {
      id: 37,
      name: 'Replacing existing finance',
      active: true,
      eligible: false,
      notice_text: "This reason is not eligible. Please choose the original
                    purpose of the funding being refinanced.",
    },
    {
      id: 38,
      name: 'Financing an export order',
      active: true,
      eligible: false,
    }
  ].sort_by {|data| data[:name] }

  def self.active
    all.select(&:active)
  end

  def eligible?
    eligible
  end
end
