defmodule Re.Repo.Migrations.CreateEmptySearchBuyerLead do
  use Ecto.Migration

  def change do
    create table(:empty_search_buyer_leads, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :city, :string
      add :state, :string
      add :url, :string

      add :city_slug, :string
      add :state_slug, :string

      add :user_uuid, references(:users, column: :uuid, type: :uuid)

      timestamps(type: :timestamptz)
    end

    create index(:empty_search_buyer_leads, [:user_uuid])
  end
end
