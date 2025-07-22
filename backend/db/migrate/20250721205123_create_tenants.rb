class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false, limit: 100
      t.string :subdomain, null: false, limit: 63
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    
    add_index :tenants, :subdomain, unique: true
    add_index :tenants, :active
    add_index :tenants, [:subdomain, :active]
  end
end
