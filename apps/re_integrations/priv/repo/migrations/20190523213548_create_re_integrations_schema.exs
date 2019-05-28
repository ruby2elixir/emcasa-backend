defmodule ReIntegrations.Repo.Migrations.CreateReIntegrationsSchema do
  use Ecto.Migration

  def up do
    execute("CREATE SCHEMA re_integrations;")
  end

  def down do
    execute("DROP SCHEMA re_integrations;")
  end
end
