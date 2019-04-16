defmodule Re.Leads.Buyer.JobQueue do
  use EctoJob.JobQueue, table_name: "buyer_leads_jobs"

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{} = job) do
    :ok
  end
end
