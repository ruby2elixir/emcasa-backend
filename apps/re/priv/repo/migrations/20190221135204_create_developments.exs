defmodule Re.Repo.Migrations.CreateDevelopments do
  use Ecto.Migration

  def up do
    create table(:developments) do
      add(:name, :string)
      add(:title, :string)
      add(:phase, :string)
      add(:builder, :string)
      add(:description, :text)
      add(:address_id, references(:addresses))

      timestamps()
    end
  end

  def down do
    drop table(:developments)
  end
end
