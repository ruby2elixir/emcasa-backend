defmodule Re.Repo.Migrations.AddStateCityFactors do
  use Ecto.Migration

  def change do
    alter table(:price_suggestion_factors) do
      add(:state, :string)
      add(:city, :string)
    end
  end
end
