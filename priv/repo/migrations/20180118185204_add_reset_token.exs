defmodule Re.Repo.Migrations.AddResetToken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:reset_token, :string)
    end
  end
end
