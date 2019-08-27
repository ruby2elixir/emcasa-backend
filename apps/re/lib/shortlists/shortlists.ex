defmodule Re.Shortlists do
  @moduledoc """
  Context for shortlists.
  """

  alias __MODULE__.Selekta

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
        create_shortlist(opportunity_id)

      shortlist ->
        {:ok, shortlist}
    end
  end

  defp create_shortlist(opportunity_id) do
    with {:ok, listing_uuids} <- get_listing_uuids_from_opportunity_preferences(opportunity_id) do
      listings = get_active_listings_by_uuid(listing_uuids)

      %Shortlist{}
      |> Shortlist.changeset(%{opportunity_id: opportunity_id})
      |> Ecto.Changeset.put_assoc(:listings, listings)
      |> Repo.insert()
    else
      _error -> {:error, :failed_to_create_new_shortlist}
    end
  end

  def generate_shortlist_from_salesforce_opportunity(opportunity_id) do
    with {:ok, listing_uuids} <- get_listing_uuids_from_opportunity_preferences(opportunity_id) do
      {:ok, get_active_listings_by_uuid(listing_uuids)}
    else
      _error -> {:error, :failed_to_create_new_shortlist}
    end
  end

  defp get_listing_uuids_from_opportunity_preferences(opportunity_id) do
    with {:ok, opportunity} <- Salesforce.get_opportunity_with_associations(opportunity_id) do
      Selekta.suggest_shortlist(opportunity)
    end
  end

  defp get_active_listings_by_uuid(uuids) do
    Listing
    |> Queries.with_uuids(uuids)
    |> Queries.active()
    |> Repo.all()
  end
end
