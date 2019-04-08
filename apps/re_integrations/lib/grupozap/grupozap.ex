defmodule ReIntegrations.Grupozap do
  @moduledoc """
  Module for handling grupozap webhook structure
  """
  require Logger

  alias Re.{
    Leads.GrupozapBuyer,
    Repo
  }

  def validate_payload(%{
        "leadOrigin" => _,
        "timestamp" => _,
        "originLeadId" => _,
        "originListingId" => _,
        "clientListingId" => client_listing_id,
        "name" => _,
        "email" => _,
        "ddd" => _,
        "phone" => _,
        "message" => _
      })
      when not is_nil(client_listing_id),
      do: :ok

  def validate_payload(payload) do
    Logger.info("Bad payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload}
  end

  def new_buyer_lead(payload) do
    %GrupozapBuyer{}
    |> GrupozapBuyer.changeset(payload)
    |> Repo.insert()
  end
end
