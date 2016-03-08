class ConvertAdjustmentRealisationsToSti < ActiveRecord::Migration
  def change
    rename_table :realisation_adjustments, :adjustments
    add_column :adjustments, :type, :string, null: false
    add_index :adjustments, :type
    add_index :adjustments, [:loan_id, :date]

    execute("
      UPDATE adjustments
      SET type = 'RealisationAdjustment' WHERE type = ''
    ")
  end
end
