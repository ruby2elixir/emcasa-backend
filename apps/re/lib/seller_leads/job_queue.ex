defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  require Ecto.Query

  alias Re.{
    PriceSuggestions.Request,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "process_price_suggestion_request", "uuid" => uuid}) do
    Request
    |> Ecto.Query.preload([:address, :user])
    |> Repo.get_by(uuid: uuid)
    |> Request.seller_lead_changeset()
    |> insert_seller_lead(multi)
    |> Repo.transaction()
    |> handle_error()
  end

  def perform(_multi, job), do: raise("Job type not handled. Job: #{Kernel.inspect(job)}")

  defp insert_seller_lead(changeset, multi),
    do: Multi.insert(multi, :insert_seller_lead, changeset)

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error(_error), do: raise("Error when performing SellerLeads.JobQueue")
end
