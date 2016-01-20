require 'spec_helper'

describe 'LendingLimits' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  before { login_as(current_user, scope: :user) }
  let(:phase) { Phase.find(1) }
  let!(:lender) { FactoryGirl.create(:lender, name: 'ACME') }

  describe 'create' do
    before do
      visit root_path
      click_link 'Manage Lenders'

      # We have 2 links to the lending limit:
      # - lender.current_annual_lending_limit_allocation
      # - lender.current_specific_lending_limit_allocation
      # See views/lenders/index.html.erb
      first(:link, "£0.00").click

      click_link 'New Lending Limit'
    end

    it 'does not continue with invalid values' do
      click_button 'Create Lending Limit'
      current_path.should == lender_lending_limits_path(lender)
    end

    it do
      choose_radio_button :allocation_type_id, LendingLimitType::Annual.id
      fill_in :name, 'This year'
      select :phase_id, 'Phase 1 (FY 2009/10)'
      fill_in :starts_on, '1/1/12'
      fill_in :ends_on, '31/12/12'
      fill_in :allocation, '5000000'
      click_button 'Create Lending Limit'

      lending_limit = LendingLimit.last
      lending_limit.lender.should == lender
      lending_limit.phase.should == phase
      lending_limit.modified_by.should == current_user
      lending_limit.active.should == true
      lending_limit.name.should == 'This year'
      lending_limit.starts_on.should == Date.new(2012, 1, 1)
      lending_limit.ends_on.should == Date.new(2012, 12, 31)
      lending_limit.allocation.should == Money.new(5_000_000_00)

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LendingLimitCreated
      admin_audit.auditable.should == lending_limit
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'update' do
    let!(:lending_limit) { FactoryGirl.create(:lending_limit, lender: lender, phase_id: phase.id, name: 'Foo', allocation: Money.new(1_000_00)) }

    before do
      visit root_path
      click_link 'Manage Lenders'
      click_link '£1,000.00'
      click_link 'Foo'
    end

    it do
      page.should_not have_selector('input[id^=lending_limit_allocation_type_id]')
      page.should_not have_selector('#lending_limit_ends_on')
      page.should_not have_selector('#lending_limit_starts_on')

      fill_in :name, 'Updated'
      select :phase_id, 'Phase 1 (FY 2009/10)'
      fill_in :allocation, '9999.99'
      click_button 'Update Lending Limit'

      lending_limit.reload
      lending_limit.lender.should == lender
      lending_limit.phase.should == phase
      lending_limit.modified_by.should == current_user
      lending_limit.active.should == true
      lending_limit.name.should == 'Updated'
      lending_limit.allocation.should == Money.new(9_999_99)

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LendingLimitEdited
      admin_audit.auditable.should == lending_limit
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'activating a LendingLimit' do
    let!(:lending_limit) { FactoryGirl.create(:lending_limit, :inactive, lender: lender, name: 'Foo', allocation: Money.new(1_000_00)) }

    before do
      visit root_path
      click_link 'Manage Lenders'
      click_link 'Lending Limits'
      click_link lending_limit.name
    end

    it do
      click_button 'Activate Lending Limit'

      lending_limit.reload
      lending_limit.active.should == true
      lending_limit.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LendingLimitActivated
      admin_audit.auditable.should == lending_limit
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  describe 'deactivating a LendingLimit' do
    let!(:lending_limit) { FactoryGirl.create(:lending_limit, :active, lender: lender, name: 'Foo', allocation: Money.new(1_000_00)) }

    before do
      visit root_path
      click_link 'Manage Lenders'
      click_link '£1,000.00'
      click_link lending_limit.name
    end

    it do
      click_button 'Deactivate Lending Limit'

      lending_limit.reload
      lending_limit.active.should == false
      lending_limit.modified_by.should == current_user

      admin_audit = AdminAudit.last!
      admin_audit.action.should == AdminAudit::LendingLimitRemoved
      admin_audit.auditable.should == lending_limit
      admin_audit.modified_by.should == current_user
      admin_audit.modified_on.should == Date.current
    end
  end

  private
    def choose_radio_button(attribute, value)
      choose "lending_limit_#{attribute}_#{value}"
    end

    def fill_in(attribute, value)
      page.fill_in "lending_limit_#{attribute}", with: value
    end

    def select(attribute, value)
      page.select value, from: "lending_limit_#{attribute}"
    end
end
