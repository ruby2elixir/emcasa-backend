defmodule :"Elixir.Re.Repo.Migrations.Add-score-to-listings" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :score, :integer
    end
  end
end
