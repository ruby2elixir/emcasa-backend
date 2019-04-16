defmodule Re.Repo.Migrations.CreateBuyerLeadsJob do
  use Ecto.Migration

  def up do
    EctoJob.Migrations.Install.up()
    EctoJob.Migrations.CreateJobTable.up("buyer_leads_jobs")
  end

  def down do
    EctoJob.Migrations.CreateJobTable.down("buyer_leads_jobs")
    EctoJob.Migrations.Install.down()
  end
end
