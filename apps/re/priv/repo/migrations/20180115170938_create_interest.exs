defmodule Re.Repo.Migrations.CreateInterest do
  use Ecto.Migration

  def change do
    create table(:interests) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :message, :text
      add :listing_id, references(:listings)

      timestamps()
    end

    create index(:interests, [:listing_id])
  end
end
