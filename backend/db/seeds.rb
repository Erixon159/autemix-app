# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample tenants for development
if Rails.env.development?
  puts "Creating sample tenants..."
  
  # Create sample tenants
  tenants_data = [
    { name: "Acme Corporation", subdomain: "acme" },
    { name: "TechStart Inc", subdomain: "techstart" },
    { name: "Global Vending Co", subdomain: "globalvending" }
  ]
  
  tenants_data.each do |tenant_data|
    tenant = Tenant.find_or_create_by(subdomain: tenant_data[:subdomain]) do |t|
      t.name = tenant_data[:name]
      t.active = true
    end
    
    if tenant.persisted?
      puts "✓ Created tenant: #{tenant.name} (#{tenant.subdomain})"
    else
      puts "✗ Failed to create tenant: #{tenant_data[:name]} - #{tenant.errors.full_messages.join(', ')}"
    end
  end
  
  puts "Seed data creation completed!"
  puts "You can now test with subdomains like:"
  puts "- acme.localhost:3001"
  puts "- techstart.localhost:3001" 
  puts "- globalvending.localhost:3001"
end
