defmodule ReIntegrations.Repo.Migrations.CreateSalesforceJobQueue do
  use Ecto.Migration

  alias EctoJob.Migrations.CreateJobTable

  def up do
    CreateJobTable.up("salesforce_jobs", prefix: "re_integrations")
  end

  def down do
    CreateJobTable.down("salesforce_jobs", prefix: "re_integrations")
  end
end
