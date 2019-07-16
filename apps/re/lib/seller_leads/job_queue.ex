defmodule Re.SellerLeads.JobQueue do
  @moduledoc """
  Module for processing seller leads to extract only necessary attributes
  """
  use EctoJob.JobQueue, table_name: "seller_lead_jobs"

  require Ecto.Query
  require Logger

  alias Re.{
    PriceSuggestions.Request,
    Repo
  }

  alias Ecto.{
    Changeset,
    Multi,
    Query
  }

  def perform(%Multi{} = multi, %{"type" => "process_price_suggestion_request", "uuid" => uuid}) do
    :ok
    # Request
    # |> Repo.get(uuid)
    # |> Grupozap.buyer_lead_changeset()
    # |> insert_buyer_lead(multi)
    # |> Repo.transaction()
    # |> handle_error()
  end
end
