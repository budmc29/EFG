require 'rails_helper'

describe 'Sub-lenders' do
  let(:current_user) { FactoryGirl.create(:cfe_admin) }
  let!(:lender) { FactoryGirl.create(:lender, name: 'ACME') }

  before { login_as(current_user, scope: :user) }

  before do
    visit root_path
    click_link 'Manage Lenders'
  end

  describe 'creating new sub-lenders' do
    before do
      click_link 'Sub-lenders'
      click_link 'New Sub-lender'
    end

    it 'does not continue with invalid values' do
      fill_in 'name', ''

      click_button 'Create Sub-lender'

      expect(page).to have_content("can't be blank")
      expect(lender.sub_lenders.count).to be_zero
    end

    it 'adds sub-lender' do
      fill_in 'name', 'EMCA'

      click_button 'Create Sub-lender'

      expect(current_path).to eql(lender_sub_lenders_path(lender))

      sub_lender = lender.sub_lenders.last
      expect(sub_lender.name).to eql('EMCA')

      admin_audit = AdminAudit.last!
      expect(admin_audit.action).to eql(AdminAudit::SubLenderCreated)
      expect(admin_audit.auditable).to eql(sub_lender)
      expect(admin_audit.modified_by).to eql(current_user)
      expect(admin_audit.modified_on).to eql(Date.current)
    end
  end

  describe 'updating existing sub-lenders' do
    let!(:sub_lender) { FactoryGirl.create(:sub_lender, lender: lender, name: 'EMCA') }

    before do
      click_link 'Sub-lenders'
      click_link 'EMCA'
    end

    it 'does not continue with invalid values' do
      fill_in 'name', ''

      click_button 'Update Sub-lender'

      expect(page).to have_content("can't be blank")
      expect(lender.sub_lenders.first.name).to eql('EMCA')
    end

    it 'changes the sub-lender' do
      fill_in 'name', 'Foo'

      click_button 'Update Sub-lender'

      expect(current_path).to eql(lender_sub_lenders_path(lender))

      sub_lender.reload
      expect(sub_lender.name).to eql('Foo')

      admin_audit = AdminAudit.last!
      expect(admin_audit.action).to eql(AdminAudit::SubLenderEdited)
      expect(admin_audit.auditable).to eql(sub_lender)
      expect(admin_audit.modified_by).to eql(current_user)
      expect(admin_audit.modified_on).to eql(Date.current)
    end
  end

  describe 'delete sub-lender' do
    let!(:sub_lender) { FactoryGirl.create(:sub_lender, lender: lender) }

    before do
      click_link 'Sub-lenders'
    end

    it do
      click_link 'Delete'
      expect(page).to_not have_content sub_lender.name
    end
  end

  private

  def fill_in(attribute, value)
    page.fill_in "sub_lender_#{attribute}", with: value
  end

end
