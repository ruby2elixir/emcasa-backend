defmodule Re.Shortlists do
  @moduledoc """
  Context for shortlists.
  """

  alias __MODULE__.{
    Client,
    Salesforce.Opportunity
  }

  alias Re.Salesforce

  @behaviour Bodyguard.Policy

  defdelegate authorize(action, user, params), to: Re.Shortlists.Policy

  def generate_shortlist_from_salesforce_opportunity(opportunity_id) do
    with {:ok, opportunity} <- Salesforce.get_opportunity(opportunity_id),
         {:ok, service_params} <- Opportunity.build(opportunity) do
      IO.inspect(opportunity)
      IO.inspect(service_params)
      {:ok, service_params}
    else
      _error -> {:error, :invalid_opportunity}
    end
  end
end
