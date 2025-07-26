class FixEmailUniquenessForMultiTenancy < ActiveRecord::Migration[8.0]
  def change
    # Remove global unique indexes on email
    remove_index :admins, :email
    remove_index :technicians, :email
    
    # Add tenant-scoped unique indexes
    add_index :admins, [:email, :tenant_id], unique: true
    add_index :technicians, [:email, :tenant_id], unique: true
  end
end
