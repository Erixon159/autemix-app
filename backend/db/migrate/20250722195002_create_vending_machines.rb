class CreateVendingMachines < ActiveRecord::Migration[8.0]
  def change
    create_table :vending_machines do |t|
      t.string :name
      t.string :location
      t.string :api_key_digest
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
