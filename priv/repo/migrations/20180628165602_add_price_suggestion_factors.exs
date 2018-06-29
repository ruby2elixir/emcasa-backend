defmodule Re.Repo.Migrations.AddPriceSuggestionFactors do
  use Ecto.Migration

  def change do
    create table(:price_suggestion_factors) do
      add :street, :string
      add :intercept, :float
      add :area, :float
      add :bathrooms, :float
      add :rooms, :float
      add :garage_spots, :float
      add :r2, :float

      timestamps()
    end
  end
end
