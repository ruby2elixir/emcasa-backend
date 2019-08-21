defmodule ReWeb.Resolvers.DuplicityChecker do
  @moduledoc """
  Resolver module duplicity checking
  """

  alias Re.{
    Addresses,
    SellerLeads.DuplicityChecker
  }

  def duplicated?(params, %{context: %{current_user: current_user}}) do
    with :ok <-
           Bodyguard.permit(
             Re.SellerLeads.DuplicityChecker,
             :check_seller_lead_duplicated,
             current_user,
             params
           ) do
      case Addresses.get(params.address) do
        {:ok, address} ->
          {:ok, DuplicityChecker.duplicated?(address, Map.get(params, :complement))}

        {:error, _} ->
          {:ok, false}
      end
    end
  end
end
