defmodule Re.Repo.Migrations.AddAccountKitFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :account_kit_id, :string
    end

    create unique_index(:users, [:account_kit_id])
  end
end
