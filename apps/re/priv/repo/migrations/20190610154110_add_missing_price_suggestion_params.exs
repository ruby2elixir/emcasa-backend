defmodule Re.Repo.Migrations.AddMissingPriceSuggestionParams do
  use Ecto.Migration

  def change do
    alter table(:price_suggestion_requests) do
      add :suites, :integer
      add :type, :string
      add :maintenance_fee, :float
    end
  end
end
