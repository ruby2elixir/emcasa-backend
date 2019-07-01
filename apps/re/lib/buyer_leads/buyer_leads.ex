defmodule Re.BuyerLeads do
  @moduledoc """
  Context boundary to Buyer Leads
  """
  require Logger
  require Ecto.Query

  alias Re.{
    BuyerLead,
    Repo
  }

  alias __MODULE__.{
    Budget,
    EmptySearch,
    Facebook,
    ImovelWeb,
    JobQueue
  }

  alias Ecto.{
    Changeset,
    Multi,
    Query
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def create(%{"source" => "facebook_buyer"} = payload) do
    %Facebook{}
    |> Facebook.changeset(payload)
    |> insert_with_job("facebook_buyer")
  end

  def create(%{"source" => "imovelweb_buyer"} = payload) do
    %ImovelWeb{}
    |> ImovelWeb.changeset(payload)
    |> insert_with_job("imovelweb_buyer")
  end

  def create_budget(params, %{uuid: uuid}) do
    params = Map.merge(params, %{user_uuid: uuid})

    %Budget{}
    |> Budget.changeset(params)
    |> insert_with_job("process_budget_buyer_lead")
    |> handle_response()
  end

  def create_empty_search(params, %{uuid: uuid}) do
    params = Map.merge(params, %{user_uuid: uuid})

    %EmptySearch{}
    |> EmptySearch.changeset(params)
    |> insert_with_job("process_empty_search_buyer_lead")
    |> handle_response()
  end

  def get(uuid), do: do_get(BuyerLead, uuid)

  def get_preloaded(uuid, preloads) do
    BuyerLead
    |> Query.preload(^preloads)
    |> do_get(uuid)
  end

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      buyer_lead -> {:ok, buyer_lead}
    end
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
  end

  defp insert_with_job(changeset, _), do: {:error, changeset}

  defp handle_response({:ok, %{add_buyer_lead: buyer_lead}}), do: {:ok, buyer_lead}

  defp handle_response(error) do
    Logger.error("Unexpected error: #{Kernel.inspect(error)}")

    {:ok, :bad_request}
  end
end
