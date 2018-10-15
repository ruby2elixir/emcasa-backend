defmodule :"Elixir.Re.Repo.Migrations.Add-default-to-listings-score" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      modify :score, :integer, default: 1
    end
  end
end
