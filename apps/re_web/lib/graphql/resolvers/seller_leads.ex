defmodule ReWeb.Resolvers.SellerLeads do
  @moduledoc """
  Resolver module for seller leads
  """

  alias Re.{
    Addresses,
    SellerLeads
  }

  def create_site(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(SellerLeads, :create_seller_lead, current_user, params) do
      SellerLeads.create_site(params)
    end
  end

  def create_broker(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(SellerLeads, :create_broker_seller_lead, current_user, params),
         {:ok, address} <- Addresses.insert_or_update(params.address) do
      attr =
        params
        |> Map.merge(%{broker_uuid: current_user.uuid, address_uuid: address.uuid})

      SellerLeads.create_broker(attr)
    end
  end

  def create_price_suggestion(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(SellerLeads, :create_price_suggestion, current_user) do
      SellerLeads.create_price_suggestion(params, current_user)
    end
  end

  def create_out_of_coverage(params, _), do: SellerLeads.create_out_of_coverage(params)
end
