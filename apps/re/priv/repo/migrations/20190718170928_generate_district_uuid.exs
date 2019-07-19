defmodule Re.Repo.Migrations.GenerateDistrictUuid do
  use Ecto.Migration

  alias Re.{
    Addresses.District,
    Repo
  }

  def up do
    alter table(:districts) do
      add :uuid, :uuid
    end

    create unique_index(:districts, [:uuid])

    flush()

    District
    |> Repo.all()
    |> Enum.map(fn req ->
      req
      |> District.changeset()
      |> Repo.update()
    end)
  end

  def down do
    alter table(:districts) do
      remove :uuid
    end
  end
end
