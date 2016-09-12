class AddNewLegalAgreementSignedToLenders < ActiveRecord::Migration
  def change
    add_column :lenders, :new_legal_agreement_signed, :boolean, default: false
  end
end
