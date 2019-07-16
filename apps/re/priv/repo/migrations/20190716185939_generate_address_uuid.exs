defmodule Re.Repo.Migrations.GenerateAddressUuid do
  use Ecto.Migration

  alias Re.{
    Address,
    Repo
  }

  def change do
    alter table(:addresses) do
      add :uuid, :uuid
    end

    flush()

    Address
    |> Repo.all()
    |> Enum.map(fn req ->
      req
      |> Address.changeset()
      |> Repo.update()
    end)
  end
end
