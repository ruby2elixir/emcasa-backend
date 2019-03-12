defmodule Re.Repo.Migrations.AlterListingUuidType do
  use Ecto.Migration

  require Ecto.Query

  def up do
    execute("ALTER TABLE listings ALTER COLUMN uuid TYPE uuid USING uuid::uuid;")
  end

  def down do
    execute("ALTER TABLE listings ALTER COLUMN uuid TYPE text;")
  end
end
