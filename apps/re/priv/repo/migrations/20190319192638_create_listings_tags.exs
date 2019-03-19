defmodule Re.Repo.Migrations.CreateListingsTags do
  use Ecto.Migration

  def change do
    create table(:listings_tags, primary_key: false) do
      add(:listing_id, references(:listings), primary_key: true)
      add(:tag_uuid, references(:tags, column: :uuid, type: :uuid), primary_key: true)
    end
  end
end
