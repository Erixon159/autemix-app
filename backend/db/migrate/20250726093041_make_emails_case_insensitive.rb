class MakeEmailsCaseInsensitive < ActiveRecord::Migration[8.0]
  def change
    # Normalize existing emails to lowercase
    execute "UPDATE admins SET email = LOWER(email)"
    execute "UPDATE technicians SET email = LOWER(email)"
    
    # Add case-insensitive indexes using PostgreSQL's LOWER function
    remove_index :admins, [:email, :tenant_id]
    remove_index :technicians, [:email, :tenant_id]
    
    add_index :admins, "LOWER(email), tenant_id", unique: true, name: "index_admins_on_lower_email_and_tenant_id"
    add_index :technicians, "LOWER(email), tenant_id", unique: true, name: "index_technicians_on_lower_email_and_tenant_id"
  end
end
