defmodule Re.Repo.Migrations.AddLatLngToAddress do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :lat, :string
      add :lng, :string
    end
  end
end
