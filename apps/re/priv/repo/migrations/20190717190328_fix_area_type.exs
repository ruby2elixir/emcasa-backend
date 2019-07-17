defmodule Re.Repo.Migrations.FixAreaType do
  use Ecto.Migration

  def up do
    alter table(:seller_leads) do
      remove :area
    end

    flush()

    alter table(:seller_leads) do
      add :area, :integer
    end
  end

  def down do
    alter table(:seller_leads) do
      remove :area
    end

    alter table(:seller_leads) do
      add :area, :string
    end
  end
end
