defmodule :"Elixir.Re.Repo.Migrations.Remove-name-from-listings" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      remove :name
    end
  end
end
