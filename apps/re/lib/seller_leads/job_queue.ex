defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  def perform(_, _), do: :ok
end
