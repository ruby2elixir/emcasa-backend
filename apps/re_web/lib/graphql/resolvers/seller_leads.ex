defmodule ReWeb.Resolvers.SellerLeads do
  @moduledoc """
  Resolver module for seller leads
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.SellerLeads

  def create_site(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(SellerLeads, :create_seller_lead, current_user, params) do
      SellerLeads.create_site(params)
    end
  end
end
