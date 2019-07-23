defmodule ReIntegrations.Repo.Migrations.CreateRoutificJobQueue do
  use Ecto.Migration

  alias EctoJob.Migrations.CreateJobTable

  def up do
    CreateJobTable.up("routific_jobs", prefix: "re_integrations")
  end

  def down do
    CreateJobTable.down("routific_jobs", prefix: "re_integrations")
  end
end
