defmodule Re.Repo.Migrations.AddFeesFielsListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :property_tax, :float
      add :maintenance_fee, :float
    end
  end
end
