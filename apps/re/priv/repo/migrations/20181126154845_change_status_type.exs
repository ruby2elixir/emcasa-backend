defmodule Re.Repo.Migrations.ChangeStatusType do
  use Ecto.Migration

  def up do
    alter table(:listings) do
      add :status, :string, default: "inactive"
    end
  end

  def down do
    alter table(:listings) do
      remove :status
    end
  end
end
