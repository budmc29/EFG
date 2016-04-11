class AddStatusAmendmentFieldsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :status_amendment_type, :string
    add_column :loans, :status_amendment_notes, :text
    add_index :loans, :status_amendment_type
  end
end
