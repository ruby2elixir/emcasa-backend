defmodule ReIntegrations.Repo.Migrations.CreateOruloJobQueue do
  use Ecto.Migration

  alias EctoJob.Migrations.{
    CreateJobTable,
    Install
  }

  def up do
    Install.up(prefix: "re_integrations")
    CreateJobTable.up("orulo_jobs", prefix: "re_integrations")
  end

  def down do
    Install.down(prefix: "re_integrations")
    CreateJobTable.down("orulo_jobs", prefix: "re_integrations")
  end
end
