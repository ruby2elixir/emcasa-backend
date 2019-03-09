defmodule Re.Repo.Migrations.AddDevelopmentToImages do
  use Ecto.Migration

  def up do
    alter table(:images) do
      add(:development_id, references(:developments))
    end
  end

  def down do
    alter table(:images) do
      remove :development_id
    end
  end
end
