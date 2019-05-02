defmodule Re.Repo.Migrations.RemoveTitleFromDevelopments do
  use Ecto.Migration

  def change do
    alter table(:developments) do
      remove :title
    end
  end
end
