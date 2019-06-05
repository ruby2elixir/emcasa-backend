defmodule Re.BuyerLeads do
  @moduledoc """
  Context boundary to Buyer Leads
  """
  require Logger

  alias Re.{
    BuyerLeads.Budget,
    BuyerLeads.EmptySearch,
    BuyerLeads.JobQueue,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create_budget(params, %{uuid: uuid}) do
    params = Map.merge(params, %{user_uuid: uuid})

    %Budget{}
    |> Budget.changeset(params)
    |> insert_with_job("process_budget_buyer_lead")
  end

  def create_empty_search(params, %{uuid: uuid}) do
    params = Map.merge(params, %{user_uuid: uuid})

    %EmptySearch{}
    |> EmptySearch.changeset(params)
    |> insert_with_job("process_empty_search_buyer_lead")
  end

  defp insert_with_job(%{valid?: true} = changeset, type) do
    uuid = Changeset.get_field(changeset, :uuid)

    Multi.new()
    |> JobQueue.enqueue(:process_buyer_lead_job, %{
      "type" => type,
      "uuid" => uuid
    })
    |> Multi.insert(:add_buyer_lead, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{add_buyer_lead: buyer_lead}} ->
        {:ok, buyer_lead}

      error ->
        Logger.error("Unexpected error: #{Kernel.inspect(error)}")

        {:ok, :bad_request}
    end
  end

  defp insert_with_job(changeset, _), do: {:error, changeset}
end
