defmodule Re.Repo.Migrations.AddUtmBuyerLead do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      add(:utm, :jsonb, default: nil)
    end
  end
end
