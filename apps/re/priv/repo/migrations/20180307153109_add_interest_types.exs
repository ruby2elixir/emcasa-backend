defmodule Re.Repo.Migrations.AddInterestTypes do
  use Ecto.Migration

  def up do
    create table(:interest_types) do
      add :name, :string

      timestamps()
    end

    flush()

    alter table(:interests) do
      add :interest_type_id, references(:interest_types)
    end

    create(index(:interests, [:interest_type_id]))
  end

  def down do
    alter table(:interests) do
      remove :interest_type_id
    end

    drop table(:interest_types)
  end
end
