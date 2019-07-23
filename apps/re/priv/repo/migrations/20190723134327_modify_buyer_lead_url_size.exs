defmodule Re.Repo.Migrations.ModifyBuyerLeadUrlSize do
  use Ecto.Migration

  def change do
    alter table(:buyer_leads) do
      modify :url, :text
    end
  end
end
