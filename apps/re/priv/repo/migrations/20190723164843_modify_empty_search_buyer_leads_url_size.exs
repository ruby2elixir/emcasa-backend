defmodule Re.Repo.Migrations.ModifyEmptySearchBuyerLeadsUrlSize do
  use Ecto.Migration

  def up do
    alter table(:empty_search_buyer_leads) do
      modify :url, :text
    end
  end

  def down do
    alter table(:empty_search_buyer_leads) do
      modify :url, :string
    end
  end
end
