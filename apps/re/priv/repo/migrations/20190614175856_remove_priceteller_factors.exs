defmodule Re.Repo.Migrations.RemovePricetellerFactors do
  use Ecto.Migration

  def change do
    drop table(:price_suggestion_factors)
  end
end
