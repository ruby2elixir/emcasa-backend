defmodule Re.Repo.Migrations.AddAddressSlug do
  use Ecto.Migration

  def up do
    alter table(:addresses) do
      add :street_slug, :string
      add :neighborhood_slug, :string
      add :city_slug, :string
      add :state_slug, :string
    end

    flush()

    Re.Address
    |> Re.Repo.all()
    |> Enum.map(&Re.Address.changeset/1)
    |> Enum.each(&Re.Repo.update/1)
  end

  def down do
    alter table(:addresses) do
      remove :street_slug
      remove :neighborhood_slug
      remove :city_slug
      remove :state_slug
    end
  end
end
