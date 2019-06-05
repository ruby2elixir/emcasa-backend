defmodule Re.Repo.Migrations.AddOruloIdToDevelopments do
  use Ecto.Migration

  def change do
    alter table(:developments) do
      add :orulo_id, :string
    end

    create unique_index(:developments, [:orulo_id])
  end
end
