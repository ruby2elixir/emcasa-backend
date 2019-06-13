defmodule Re.Repo.Migrations.CreateListingsJobs do
  use Ecto.Migration

  alias EctoJob.Migrations.CreateJobTable

  def up do
    CreateJobTable.up("listings_jobs")
  end

  def down do
    CreateJobTable.up("listings_jobs")
  end
end
