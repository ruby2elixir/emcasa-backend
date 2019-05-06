defmodule Re.Repo.Migrations.GenerateInterestsUuid do
  use Ecto.Migration

  require Ecto.Query

  def up do
    Ecto.Query.from(i in "interests", select: i.id)
    |> Re.Repo.all()
    |> Enum.map(
      &Ecto.Query.from(i in "interests", where: i.id == ^&1, update: [set: [uuid: ^Ecto.UUID.bingenerate()]])
    )
    |> Enum.map(&Re.Repo.update_all(&1, []))
  end

  def down do
  end
end
