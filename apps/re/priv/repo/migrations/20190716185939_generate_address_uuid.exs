defmodule Re.Repo.Migrations.GenerateAddressUuid do
  use Ecto.Migration

  alias Re.{
    Address,
    Repo
  }

  def up do
    alter table(:addresses) do
      add :uuid, :uuid
    end

    create unique_index(:addresses, [:uuid])

    flush()

    Address
    |> Repo.all()
    |> Enum.map(fn req ->
      req
      |> Address.changeset()
      |> Repo.update()
    end)
  end

  def down do
    alter table(:addresses) do
      remove :uuid
    end
  end
end
