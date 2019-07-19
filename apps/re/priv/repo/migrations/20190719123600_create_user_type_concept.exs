defmodule Re.Repo.Migrations.CreateUserTypeConcept do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :type, :string, default: "common"
      add :sales_force_id, :string
    end

    flush()
  end

  def down do
    alter table(:users) do
      remove :type
      remove :sales_force_id
    end
  end
end
