class RemoveDeviseAndAddCustomAuth < ActiveRecord::Migration[8.0]
  def change
    # Remove Devise columns from admins table
    remove_column :admins, :encrypted_password, :string
    remove_column :admins, :reset_password_token, :string
    remove_column :admins, :reset_password_sent_at, :datetime
    remove_column :admins, :remember_created_at, :datetime
    remove_column :admins, :sign_in_count, :integer
    remove_column :admins, :current_sign_in_at, :datetime
    remove_column :admins, :last_sign_in_at, :datetime
    remove_column :admins, :current_sign_in_ip, :string
    remove_column :admins, :last_sign_in_ip, :string
    remove_column :admins, :unlock_token, :string
    remove_column :admins, :jti, :string
    
    # Remove Devise columns from technicians table
    remove_column :technicians, :encrypted_password, :string
    remove_column :technicians, :reset_password_token, :string
    remove_column :technicians, :reset_password_sent_at, :datetime
    remove_column :technicians, :remember_created_at, :datetime
    remove_column :technicians, :sign_in_count, :integer
    remove_column :technicians, :current_sign_in_at, :datetime
    remove_column :technicians, :last_sign_in_at, :datetime
    remove_column :technicians, :current_sign_in_ip, :string
    remove_column :technicians, :last_sign_in_ip, :string
    remove_column :technicians, :unlock_token, :string
    remove_column :technicians, :jti, :string
    
    # Add custom authentication columns to admins table
    add_column :admins, :password_digest, :string, null: false
    add_column :admins, :last_login_at, :datetime
    add_column :admins, :last_login_ip, :string
    
    # Add custom authentication columns to technicians table
    add_column :technicians, :password_digest, :string, null: false
    add_column :technicians, :last_login_at, :datetime
    add_column :technicians, :last_login_ip, :string
    
    # Note: failed_attempts and locked_at columns already exist from Devise
    # and will be reused for our custom lockout functionality
  end
end
