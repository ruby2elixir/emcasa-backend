defmodule Re.Repo.Migrations.RemoveUniqueEmailConstraint do
  use Ecto.Migration

  def up do
    drop unique_index(:users, [:email])
  end

  def down do
    create unique_index(:users, [:email])
  end
end
