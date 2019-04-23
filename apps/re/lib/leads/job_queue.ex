defmodule Re.Leads.Buyer.JobQueue do
  @moduledoc """
  Module for processing buyer leads to extract only necessary attributes
  Also attempts to associate user and listings
  """
  use EctoJob.JobQueue, table_name: "buyer_leads_jobs"

  require Logger

  alias Re.{
    Leads.GrupozapBuyer,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "grupozap_buyer_lead", "uuid" => uuid}) do
    GrupozapBuyer
    |> Repo.get(uuid)
    |> GrupozapBuyer.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
  end

  def perform(_multi, job) do
    Logger.warn("Job format not handled. Job: #{Kernel.inspect(job)}")

    raise "Job not handled"
  end

  defp insert_buyer_lead(changeset, multi), do: Multi.insert(multi, :insert_buyer_lead, changeset)
end
