defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  require Ecto.Query

  alias Re.{
    PriceSuggestions.Request,
    Repo,
    SellerLeads,
    SellerLeads.Salesforce.Client
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def perform(%Multi{} = multi, %{"type" => "process_price_suggestion_request", "uuid" => uuid}) do
    Request
    |> Ecto.Query.preload([:address, :user])
    |> Repo.get_by(uuid: uuid)
    |> Request.seller_lead_changeset()
    |> insert_seller_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(%Multi{} = multi, %{"type" => "create_lead_salesforce", "uuid" => uuid}) do
    {:ok, seller_lead} = SellerLeads.get_preloaded(uuid, [:address, :user])

    multi
    |> Multi.run(:create_salesforce_lead, fn _repo, _changes ->
      Client.create_lead(seller_lead)
    end)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  defp insert_seller_lead(changeset, multi) do
    uuid = Changeset.get_field(changeset, :uuid)

    multi
    |> Multi.insert(:insert_seller_lead, changeset)
    |> __MODULE__.enqueue(:salesforce_job, %{"type" => "create_lead_salesforce", "uuid" => uuid})
  end

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error(_error), do: raise("Error when performing SellerLeads.JobQueue")
end
