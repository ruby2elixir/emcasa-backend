defmodule Re.Repo.Migrations.AddUtmInfoToSellerLead do
  use Ecto.Migration

  def change do
    alter table(:seller_leads) do
      add :utm, :jsonb, default: nil
    end
  end
end
