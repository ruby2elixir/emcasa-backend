defmodule Re.Repo.Migrations.AddImageDescription do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :description, :text
    end
  end
end
