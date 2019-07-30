defmodule Re.Repo.Migrations.AddSuggestedPriceSellerLead do
  use Ecto.Migration

  def change do
    alter table(:seller_leads) do
      add :suggested_price, :float
    end
  end
end
