defmodule Re.Repo.Migrations.AddCoveredAttribute do
  use Ecto.Migration

  def change do
    alter table(:price_suggestion_requests) do
      add :is_covered, :boolean
    end
  end
end
