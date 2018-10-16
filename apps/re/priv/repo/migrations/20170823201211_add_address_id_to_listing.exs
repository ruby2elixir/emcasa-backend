defmodule Re.Repo.Migrations.AddAddressIdToListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :address_id, references(:addresses)
    end
  end
end
