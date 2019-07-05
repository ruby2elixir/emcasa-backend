defmodule ReIntegrations.Zapier do
  @moduledoc """
  Module for handling zapier webhook structure
  """
  require Logger

  alias Re.{
    BuyerLeads,
    SellerLeads
  }

  @buyer_lead_sources ~w(facebook_buyer imovelweb_buyer walkin_offline_buyer)
  @seller_lead_sources ~w(facebook_seller)

  def handle_payload(%{"source" => source} = payload) when source in @buyer_lead_sources do
    BuyerLeads.create(payload)
  end

  def handle_payload(%{"source" => source} = payload) when source in @seller_lead_sources do
    SellerLeads.create(payload)
  end

  def handle_payload(payload) do
    Logger.warn("Invalid payload source. Payload: #{Kernel.inspect(payload)}")

    {:error, :unexpected_payload, payload}
  end
end
