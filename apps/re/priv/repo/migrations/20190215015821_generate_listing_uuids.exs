defmodule Re.Repo.Migrations.GenerateListingUuids do
  use Ecto.Migration

  require Ecto.Query

  def up do
    alter table(:listings) do
      add :uuid, :string
    end

    flush()

    Ecto.Query.from(l in "listings", select: l.id)
    |> Re.Repo.all()
    |> Enum.map(
      &Ecto.Query.from(l in "listings", where: l.id == ^&1, update: [set: [uuid: ^UUID.uuid4()]])
    )
    |> Enum.map(&Re.Repo.update_all(&1, []))

    flush()

    create(unique_index(:listings, [:uuid]))
  end

  def down do
    alter table(:listings) do
      remove :uuid
    end
  end
end
