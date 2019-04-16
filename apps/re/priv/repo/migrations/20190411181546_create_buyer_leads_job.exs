defmodule Re.Repo.Migrations.CreateBuyerLeadsJob do
  use Ecto.Migration

  alias EctoJob.Migrations.{
    CreateJobTable,
    Install
  }

  def up do
    Install.up()
    CreateJobTable.up("buyer_leads_jobs")
  end

  def down do
    CreateJobTable.down("buyer_leads_jobs")
    Install.down()
  end
end
