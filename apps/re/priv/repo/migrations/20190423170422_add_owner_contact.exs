defmodule Re.Repo.Migrations.AddOwnerContact do
  use Ecto.Migration

  def change do
    create table(:owner_contacts, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :name_slug, :string, null: false
      add :phone, :string, null: false
      add :email, :string
      add :additional_phones, {:array, :string}, default: []
      add :additional_emails, {:array, :string}, default: []

      timestamps(type: :timestamptz)
    end

    create unique_index(
             :owner_contacts,
             [:name_slug, :phone],
             name: :owner_contacts_name_phone_index
           )
  end
end
