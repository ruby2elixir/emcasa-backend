defmodule Re.Repo.Migrations.AddStreetNumberToAddress do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :street_number, :string
    end
  end
end
