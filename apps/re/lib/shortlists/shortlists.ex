defmodule Re.Shortlists do
  @moduledoc """
  Context for shortlists.
  """

  alias __MODULE__.{
    Client,
    Salesforce.Opportunity
  }

  alias Re.{
    Listing,
    Listings.Queries,
    Repo,
    Salesforce,
    Shortlist
  }

  @behaviour Bodyguard.Policy

  defdelegate authorize(action, user, params), to: Re.Shortlists.Policy

  def get_or_create(opportunity_id) do
    case Repo.get_by(Shortlist, opportunity_id: opportunity_id) do
      nil ->
        with {:ok, opportunity} <- Salesforce.get_opportunity(opportunity_id),
             {:ok, params} <- create_params(opportunity),
             {:ok, listing_uuids} <- get_shortlist(params) do
          listings = get_active_listings_by_uuid(listing_uuids)

          %Shortlist{}
          |> Shortlist.changeset(%{opportunity_id: opportunity_id})
          |> Ecto.Changeset.put_assoc(:listings, listings)
          |> Repo.insert()
        else
          _error -> {:error, :invalid_opportunity}
        end

      shortlist ->
        {:ok, shortlist}
    end
  end

  def generate_shortlist_from_salesforce_opportunity(opportunity_id) do
    with {:ok, opportunity} <- Salesforce.get_opportunity(opportunity_id),
         {:ok, params} <- create_params(opportunity),
         {:ok, listing_uuids} <- get_shortlist(params) do
      get_active_listings_by_uuid(listing_uuids)
    else
      _error -> {:error, :invalid_opportunity}
    end
  end

  defp create_params(opportunity) do
    opportunity
    |> Opportunity.build()
    |> case do
      {:ok, params} -> {:ok, Map.put(%{}, :characteristcs, params)}
      error -> error
    end
  end

  defp get_shortlist(params) do
    with {:ok, %{body: body}} <- Client.get_listings_uuids(params) do
      Jason.decode(body)
    end
  end

  defp get_active_listings_by_uuid(uuids) do
    Listing
    |> Queries.with_uuids(uuids)
    |> Queries.active()
    |> Repo.all()
  end
end
