defmodule ReIntegrations.Repo.Migrations.CreateOruloJobQueue do
  use Ecto.Migration

  alias EctoJob.Migrations.CreateJobTable

  def up do
    CreateJobTable.up("orulo_fetch_jobs")
  end

  def down do
    CreateJobTable.down("orulo_fetch_jobs")
  end
end
