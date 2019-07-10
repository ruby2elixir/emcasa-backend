defmodule Re.Repo.Migrations.AddSortOrderColumnInDistricts do
  use Ecto.Migration

  def change do
    alter table(:districts) do
      add :sort_order, :integer
    end
  end
end
