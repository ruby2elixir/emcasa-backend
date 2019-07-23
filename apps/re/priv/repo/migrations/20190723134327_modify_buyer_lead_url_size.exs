defmodule Re.Repo.Migrations.ModifyBuyerLeadUrlSize do
  use Ecto.Migration

  def up do
    alter table(:buyer_leads) do
      modify :url, :text
    end
  end

  def down do
    alter table(:buyer_leads) do
      modify :url, :string
    end
  end
end
