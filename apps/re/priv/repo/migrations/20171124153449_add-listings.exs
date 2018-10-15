defmodule :"Elixir.Re.Repo.Migrations.Add-listings" do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :listing_id, references(:listings)
      add :filename, :string
      add :position, :integer

      timestamps()
    end
  end
end
