defmodule Re.Repo.Migrations.AddRegisteringConfirmationFields do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :confirmation_token, :string
      add :confirmed, :boolean
    end

    flush()
    Re.Repo.update_all(Re.User, set: [confirmed: true])
  end

  def down do
    alter table(:users) do
      remove :confirmation_token
      remove :confirmed
    end
  end
end
