defmodule Re.Repo.Migrations.RemoveZapHighlightsAndZapSuperHighlights do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      remove :zap_highlight
      remove :zap_super_highlight
    end
  end
end
