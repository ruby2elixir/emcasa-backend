defmodule Re.BuyerLeads.JobQueue do
  @moduledoc """
  Module for processing buyer leads to extract only necessary attributes
  Also attempts to associate user and listings
  """
  use EctoJob.JobQueue, table_name: "buyer_leads_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    BuyerLeads,
    BuyerLeads.Budget,
    BuyerLeads.EmptySearch,
    BuyerLeads.Facebook,
    BuyerLeads.Grupozap,
    BuyerLeads.ImovelWeb,
    BuyerLeads.Salesforce.Client,
    Interest,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi,
    Query
  }

  def perform(%Multi{} = multi, %{"type" => "grupozap_buyer_lead", "uuid" => uuid}) do
    Grupozap
    |> Repo.get(uuid)
    |> Grupozap.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "facebook_buyer", "uuid" => uuid}) do
    Facebook
    |> Repo.get(uuid)
    |> Facebook.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "imovelweb_buyer", "uuid" => uuid}) do
    ImovelWeb
    |> Repo.get(uuid)
    |> ImovelWeb.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "interest", "uuid" => uuid}) do
    Interest
    |> Query.preload(listing: [:address])
    |> Repo.get_by(uuid: uuid)
    |> Interest.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "process_budget_buyer_lead", "uuid" => uuid}) do
    Budget
    |> Query.preload(:user)
    |> Repo.get(uuid)
    |> Budget.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "process_empty_search_buyer_lead", "uuid" => uuid}) do
    EmptySearch
    |> Query.preload(:user)
    |> Repo.get(uuid)
    |> EmptySearch.buyer_lead_changeset()
    |> insert_buyer_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "create_lead_salesforce", "uuid" => uuid}) do
    {:ok, buyer_lead} = BuyerLeads.get_preloaded(uuid, listing: :address)

    multi
    |> Multi.run(:create_salesforce_lead, fn _repo, _changes ->
      Client.create_lead(buyer_lead)
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  def requeue_all(multi) do
    __MODULE__
    |> Query.where([jq], jq.state == "FAILED")
    |> Repo.all()
    |> Enum.reduce(multi, fn job, multi ->
      __MODULE__.requeue(multi, "retry_job_#{job.id}", job)
    end)
    |> Repo.transaction()
  end

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error(error) do
    Sentry.capture_message("error when performing BuyerLeads.JobQueue",
      extra: %{error: error}
    )

    raise "Error when performing BuyerLeads.JobQueue"
  end

  defp insert_buyer_lead(changeset, multi) do
    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:insert_buyer_lead, changeset)
    |> __MODULE__.enqueue(:salesforce_job, %{"type" => "create_lead_salesforce", "uuid" => uuid})
  end
end
