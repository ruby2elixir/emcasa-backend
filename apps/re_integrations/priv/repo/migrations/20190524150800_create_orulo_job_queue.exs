defmodule ReIntegrations.Repo.Migrations.CreateOruloJobQueue do
  use Ecto.Migration

  def up do
    EctoJob.Migrations.CreateJobTable.up("orulo_fetch_jobs")
  end

  def down do
    EctoJob.Migrations.Install.down()
  end
end
