defmodule Re.Repo.Migrations.AddStatusToUnits do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add(:status, :string)
    end
  end
end
