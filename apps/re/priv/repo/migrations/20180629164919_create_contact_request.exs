defmodule Re.Repo.Migrations.CreateContactRequest do
  use Ecto.Migration

  def change do
    create table(:contact_requests) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :message, :text

      add :user_id, references(:users)

      timestamps()
    end

    create index(:contact_requests, [:user_id])
  end
end
