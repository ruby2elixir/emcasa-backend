defmodule Re.Repo.Migrations.CreateUnitMirrorJob do
  use Ecto.Migration

  alias EctoJob.Migrations.CreateJobTable

  def up do
    CreateJobTable.up("units_jobs")
  end

  def down do
    CreateJobTable.down("units_jobs")
  end
end
