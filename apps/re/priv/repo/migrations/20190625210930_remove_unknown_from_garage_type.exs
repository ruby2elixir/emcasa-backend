defmodule Re.Repo.Migrations.RemoveUnknownFromGarageType do
  use Ecto.Migration

  require Ecto.Query

  def up do
    "listings"
    |> Ecto.Query.where([l], l.garage_type == "unknown")
    |> Re.Repo.update_all(set: [garage_type: nil])

    "units"
    |> Ecto.Query.where([l], l.garage_type == "unknown")
    |> Re.Repo.update_all(set: [garage_type: nil])
  end

  def down do
  end
end
