defmodule Re.Repo.Migrations.AddBuyerLeadsLocation do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add :location, :string
    end
  end
end
