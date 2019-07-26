defmodule Re.PriceSuggestions do
  @moduledoc """
  Module for fetching and saving suggested prices from priceteller API
  """
  NimbleCSV.define(PriceSuggestionsParser, separator: ",", escape: "\"")

  alias Re.{
    Listing,
    PriceSuggestions.Request,
    PriceTeller,
    Repo,
    SellerLeads.JobQueue
  }

  alias Ecto.{
    Changeset,
    Multi
  }

  def suggest_price(%Request{} = request) do
    request
    |> preload_address()
    |> do_suggest_price()
  end

  def suggest_price(%Listing{} = listing) do
    listing
    |> preload_address()
    |> do_suggest_price()
    |> persist_suggested_price(listing)
  end

  def suggest_price(params), do: do_suggest_price(params)

  defp persist_suggested_price({:ok, suggested_price}, listing) do
    listing
    |> Listing.changeset(%{suggested_price: suggested_price.listing_price_rounded})
    |> Repo.update()

    {:ok, suggested_price}
  end

  defp persist_suggested_price(response, _), do: response

  defp do_suggest_price(params) do
    params
    |> map_params()
    |> PriceTeller.ask()
  end

  defp map_params(params) do
    %{
      type: map_type(params.type),
      zip_code: String.replace(params.address.postal_code, "-", ""),
      street_number: params.address.street_number,
      area: params.area,
      bathrooms: params.bathrooms,
      bedrooms: params.rooms,
      suites: params.suites,
      parking: params.garage_spots,
      condo_fee: round_if_not_nil(params.maintenance_fee),
      lat: params.address.lat,
      lng: params.address.lng
    }
  end

  defp map_type("Apartamento"), do: "APARTMENT"
  defp map_type("Casa"), do: "HOME"
  defp map_type("Cobertura"), do: "PENTHOUSE"
  defp map_type(type), do: type

  defp round_if_not_nil(nil), do: 0
  defp round_if_not_nil(maintenance_fee), do: round(maintenance_fee)

  defp preload_address(%Listing{} = listing), do: Repo.preload(listing, :address)

  defp preload_address(params), do: params

  def create_request(params) do
    with changeset <- Request.changeset(%Request{}, params),
         suggested_price <- do_suggest_price(params),
         changeset <- set_suggested_price(changeset, suggested_price) do
      save_price_suggestion(changeset)
    end
  end

  defp set_suggested_price(changeset, {:ok, suggested_price}) do
    changeset
    |> Request.changeset(%{suggested_price: suggested_price.listing_price_rounded})
    |> Request.changeset(suggested_price)
  end

  defp set_suggested_price(changeset, _), do: changeset

  defp save_price_suggestion(changeset) do
    uuid = Changeset.get_field(changeset, :uuid)

    Ecto.Multi.new()
    |> Multi.insert(:insert_price_suggestion_request, changeset)
    |> JobQueue.enqueue(:seller_lead_job, %{
      "type" => "process_price_suggestion_request",
      "uuid" => uuid
    })
    |> Repo.transaction()
    |> return_insertion()
  end

  defp return_insertion({:ok, %{insert_price_suggestion_request: request}}), do: {:ok, request}

  defp return_insertion(error), do: error
end
