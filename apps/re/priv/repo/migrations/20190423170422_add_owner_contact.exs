defmodule Re.Repo.Migrations.AddOwnerContact do
  use Ecto.Migration

  def change do
    create table(:owners_contacts, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :name_slug, :string, null: false
      add :phone, :string, null: false
      add :email, :string

      timestamps(type: :timestamptz)
    end

    create unique_index(
             :owners_contacts,
             [:name_slug, :phone],
             name: :owners_contacts_name_phone_index
           )
  end
end
