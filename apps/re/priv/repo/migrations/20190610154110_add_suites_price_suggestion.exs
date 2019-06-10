defmodule Re.Repo.Migrations.AddSuitesPriceSuggestion do
  use Ecto.Migration

  def change do
    alter table(:price_suggestion_requests) do
      add :suites, :integer
    end
  end
end
