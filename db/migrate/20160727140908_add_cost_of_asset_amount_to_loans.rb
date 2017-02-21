class AddCostOfAssetAmountToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :cost_of_asset_amount, :integer, limit: 8
  end
end
