defmodule Re.Repo.Migrations.AddDistrictSlugs do
  use Ecto.Migration

  def change do
    alter table(:districts) do
      add :state_slug, :string
      add :city_slug, :string
      add :name_slug, :string
    end
  end
end
