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
  end

  def down do
    alter table(:listings) do
      remove :status
    end
  end
end
