defmodule :"Elixir.Re.Repo.Migrations.Add-type-to-listings" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :type, :string, default: "Apartamento"
    end
  end
end
