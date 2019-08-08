defmodule Re.Repo.Migrations.DropInterestTypes do
  use Ecto.Migration

  def up do
    alter table(:interests) do
      remove :interest_type_id
    end

    flush()

    drop table(:interest_types)
  end

  def down do
    create table(:interest_types) do
      add :name, :string
      add :enabled, :boolean

      timestamps()
    end

    alter table(:interests) do
      add :interest_type_id, references(:interest_types)
    end

    create(index(:interests, [:interest_type_id]))
  end
end
