defmodule Re.Repo.Migrations.AddDistrictSlugs do
  use Ecto.Migration

  def change do
    alter table(:districts) do
      add :state_slug, :string
      add :city_slug, :string
      add :name_slug, :string
    end

    flush()

    Re.Addresses.District
    |> Re.Repo.all()
    |> Enum.map(&Re.Addresses.District.changeset/1)
    |> Enum.each(&Re.Repo.update/1)
  end
end
