defmodule Re.Repo.Migrations.RenameDistrictsStatuses do
  use Ecto.Migration

  require Ecto.Query

  def up do
    "districts"
    |> Ecto.Query.where([d], d.status == "active")
    |> Re.Repo.update_all(set: [status: "covered"])

    flush()

    "districts"
    |> Ecto.Query.where([d], d.status == "inactive")
    |> Re.Repo.update_all(set: [status: "uncovered"])
  end

  def down do
    "districts"
    |> Ecto.Query.where([d], d.status == "covered")
    |> Re.Repo.update_all(set: [status: "active"])

    flush()

    "districts"
    |> Ecto.Query.where([d], d.status == "uncovered")
    |> Re.Repo.update_all(set: [status: "inactive"])
  end
end
