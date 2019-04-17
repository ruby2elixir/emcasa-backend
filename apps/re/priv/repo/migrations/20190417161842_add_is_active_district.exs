defmodule Re.Repo.Migrations.AddIsActiveDistrict do
  use Ecto.Migration

  import Ecto.Query

  def up do
    alter table(:districts) do
      add :status, :string
    end

    flush()

    q = from(d in "districts")

    Re.Repo.update_all(q, set: [status: "active"])
  end

  def down do
    alter table(:districts) do
      remove :status
    end
  end
end
