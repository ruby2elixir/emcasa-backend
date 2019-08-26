defmodule Re.Repo.Migrations.CreateShortlists do
  use Ecto.Migration

  def change do
    create table(:shortlists, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :opportunity_id, :string, null: false
      add :account_name, :string, null: false
      add :owner_name, :string, null: false

      timestamps()
    end

    create table(:listings_shortlists, primary_key: false) do
      add :listing_uuid, references(:listings, column: :uuid, type: :uuid), primary_key: true

      add :shortlist_uuid,
          references(:shortlists, column: :uuid, type: :uuid, on_delete: :delete_all),
          primary_key: true
    end

    create index(:listings_shortlists, [:listing_uuid, :shortlist_uuid])
  end
end
