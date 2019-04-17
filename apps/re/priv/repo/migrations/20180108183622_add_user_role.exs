defmodule Re.Repo.Migrations.AddUserRole do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter table(:users) do
      add :role, :string
    end
  end

  def down do
    alter table(:users) do
      remove :role
    end
  end
end
