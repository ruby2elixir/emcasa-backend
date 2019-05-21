defmodule Re.Repo.Migrations.AddNeighborhoodBuyerLeads do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add :neighborhood, :string
    end
  end
end
