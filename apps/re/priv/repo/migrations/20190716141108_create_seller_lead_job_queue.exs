defmodule Re.Repo.Migrations.CreateSellerLeadJobQueue do
  use Ecto.Migration

  alias EctoJob.Migrations.CreateJobTable

  def up do
    CreateJobTable.up("seller_lead_jobs")
  end

  def down do
    CreateJobTable.down("seller_lead_jobs")
  end
end
