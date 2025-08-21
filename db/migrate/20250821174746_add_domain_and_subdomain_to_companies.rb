class AddDomainAndSubdomainToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :domain, :string
    add_column :companies, :subdomain, :string
  end
end
