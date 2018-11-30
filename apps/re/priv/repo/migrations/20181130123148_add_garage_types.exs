defmodule Re.Repo.Migrations.AddGarageTypes do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :garage_type, :string
    end
  end
end
