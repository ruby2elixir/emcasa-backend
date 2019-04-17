defmodule Re.Repo.Migrations.AddIsActiveDistrict do
  use Ecto.Migration

  import Ecto.Query

  def up do
    alter table(:districts) do
      add :is_active, :boolean
    end

    flush()

    q = from(d in "districts")

    Re.Repo.update_all(q, set: [is_active: true])
  end

  def down do
    alter table(:districts) do
      remove :is_active
    end
  end
end
