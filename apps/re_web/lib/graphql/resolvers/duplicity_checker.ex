defmodule ReWeb.Resolvers.DuplicityChecker do
  @moduledoc """
  Resolver module duplicity checking
  """

  alias Re.{
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
      DuplicityChecker.duplicated(params.address, Map.get(params, :complement))
    end
  end
end
