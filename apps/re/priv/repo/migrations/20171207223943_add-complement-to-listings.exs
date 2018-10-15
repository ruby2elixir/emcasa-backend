defmodule :"Elixir.Re.Repo.Migrations.Add-complement-to-listings" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :complement, :string
    end
  end
end
