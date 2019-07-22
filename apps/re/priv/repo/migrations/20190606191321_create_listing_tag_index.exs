defmodule Re.Repo.Migrations.CreateListingTagIndex do
  use Ecto.Migration

  def change do
    create index(:listings_tags, [:listing_uuid, :tag_uuid])
  end
end
