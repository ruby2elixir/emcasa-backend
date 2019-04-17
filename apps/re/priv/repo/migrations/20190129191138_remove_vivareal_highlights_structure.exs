defmodule Re.Repo.Migrations.RemoveVivarealHighlightsStructure do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:vivareal_highlights, [:listing_id])
    drop_if_exists table(:vivareal_highlights)

    remove_column_if_exists(:listings, :vivareal_highlight)
  end

  defp remove_column_if_exists(table, column) do
    case column_exists?(table, column) do
      true ->
        alter table(table) do
          remove column
        end

      _ ->
        nil
    end
  end

  defp column_exists?(table, column) do
    table = Atom.to_string(table)
    column = Atom.to_string(column)

    {:ok, result} =
      Ecto.Adapters.SQL.query(
        Re.Repo,
        "SELECT column_name " <>
          "FROM information_schema.columns " <>
          "WHERE table_name=$1 and column_name=$2",
        [table, column]
      )

    Map.get(result, :num_rows) == 1
  end
end
