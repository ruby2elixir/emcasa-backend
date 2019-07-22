defmodule Re.Repo.Migrations.CreateUserTypeConcept do
  use Ecto.Migration

  import Ecto.Query

  def up do
    alter table(:users) do
      add :type, :string
      add :salesforce_id, :string
    end

    create unique_index(:users, [:salesforce_id])

    flush()

    q = from(u in "users")
    Re.Repo.update_all(q, set: [type: "property_owner"])
  end

  def down do
    alter table(:users) do
      remove :type
      remove :sales_force_id
    end
  end
end
