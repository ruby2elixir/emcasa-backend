defmodule Re.Repo.Migrations.AddressUniqueConstraint do
  use Ecto.Migration

  def up do
    create unique_index(:addresses, [:street, :postal_code, :street_number], name: :unique_address)
  end

  def down do
    drop index(:addresses, [:street, :postal_code, :street_number], name: :unique_address)
  end
end
