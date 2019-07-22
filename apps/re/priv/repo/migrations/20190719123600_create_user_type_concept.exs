defmodule Re.Repo.Migrations.CreateUserTypeConcept do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :type, :string
      add :salesforce_id, :string
    end

    create unique_index(:users, [:salesforce_id])

    flush()

    q = from(d in "users")
    Re.Repo.update_all(q, set: [type: "common"])
  end

  def down do
    drop_if_exists unique_index(:users, [:salesforce_id])

    alter table(:users) do
      remove :type
      remove :sales_force_id
    end
  end
end
