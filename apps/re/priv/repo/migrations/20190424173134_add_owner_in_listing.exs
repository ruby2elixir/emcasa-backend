defmodule Re.Repo.Migrations.AddOwnerInListing do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :owner_contact_uuid, references(:owner_contacts, column: :uuid, type: :uuid)
    end
  end
end
