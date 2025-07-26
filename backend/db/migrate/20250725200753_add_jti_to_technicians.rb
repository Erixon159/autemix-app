class AddJtiToTechnicians < ActiveRecord::Migration[8.0]
  def change
    add_column :technicians, :jti, :string, null: false
    add_index :technicians, :jti, unique: true
  end
end
