defmodule Re.Repo.Migrations.EmbedAddressCoberageNotification do
  use Ecto.Migration

  def change do
    alter table(:notify_when_covered) do
      add :state, :string
      add :city, :string
      add :neighborhood, :string

      remove :user_id
      remove :address_id
    end
  end
end
