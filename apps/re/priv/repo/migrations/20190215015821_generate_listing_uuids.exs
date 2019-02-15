defmodule Re.Repo.Migrations.GenerateListingUuids do
  use Ecto.Migration

  def up do
    alter table(:listings) do
      add :uuid, :string
    end

    flush()

    Re.Listing
    |> Re.Repo.all()
    |> Enum.map(&Re.Listing.uuid_changeset(&1, %{uuid: UUID.uuid4()}))
    |> Enum.each(&Re.Repo.update/1)

    flush()

    create unique_index(:listings, [:uuid])
  end

  def down do
    alter table(:listings) do
      remove :uuid
    end
  end
end
