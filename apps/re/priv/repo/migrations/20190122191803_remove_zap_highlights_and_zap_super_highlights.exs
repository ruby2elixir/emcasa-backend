defmodule Re.Repo.Migrations.RemoveZapHighlightsAndZapSuperHighlights do
  use Ecto.Migration

  def change do
    drop unique_index(:zap_highlights, [:listing_id])
    drop table(:zap_highlights)

     drop unique_index(:zap_super_highlights, [:listing_id])
    drop table(:zap_super_highlights)
  end
end
