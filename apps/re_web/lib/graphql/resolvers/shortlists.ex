defmodule ReWeb.Resolvers.Shortlists do
  @moduledoc """
  Resolver module for shortlists queries and mutations
  """
  alias Re.Shortlists

  def index(%{opportunity_id: opportunity_id}, %{context: %{current_user: current_user}}) do
    case Bodyguard.permit(Shortlists, :shortlist_listings, current_user, %{}) do
      :ok -> Shortlists.generate_shortlist_from_salesforce_opportunity(opportunity_id)
      error -> error
    end
  end
end
