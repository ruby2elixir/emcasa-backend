defmodule Re.Repo.Migrations.AddSuggestedPriceField do
  use Ecto.Migration

  def change do
    alter table(:price_suggestion_requests) do
      add :suggested_price, :float
    end
  end
end
