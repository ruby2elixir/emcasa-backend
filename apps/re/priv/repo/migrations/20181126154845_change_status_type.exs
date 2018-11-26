defmodule Re.Repo.Migrations.ChangeStatusType do
  use Ecto.Migration

  def up do
    alter table(:listings) do
      add :status, :string, default: "inactive"
    end

    flush()

    import Ecto.Query

    Re.Listing
    |> where([l], l.is_active == true)
    |> Re.Repo.update_all(set: [status: "active"])

    flush()

    alter table(:listings) do
      remove :is_active
    end
  end

  def down do
    alter table(:listings) do
      add :is_active, :boolean, default: false
    end

    flush()

    import Ecto.Query

    Re.Listing
    |> where([l], l.status == "active")
    |> Re.Repo.update_all(set: [is_active: true])

    flush()

    alter table(:listings) do
      remove :status
    end
  end
end
