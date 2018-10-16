defmodule Re.Repo.Migrations.AddDeviceToken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :device_token, :string
    end
  end
end
