defmodule Re.Repo.Migrations.RemoveEmailLoginFields do
  use Ecto.Migration

  def up do
    alter table(:users) do
      remove :password_hash
      remove :confirmed
      remove :reset_token
      remove :confirmation_token
    end
  end

  def down do
    alter table(:users) do
      add :password_hash, :string
      add :confirmed, :boolean
      add :reset_token, :string
      add :confirmation_token, :string
    end
  end
end
