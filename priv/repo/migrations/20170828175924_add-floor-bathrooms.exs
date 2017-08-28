defmodule :"Elixir.Re.Repo.Migrations.Add-floor-bathrooms" do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :bathrooms, :integer
      add :floor, :string
    end
  end
end
