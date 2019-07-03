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
    User
  }

  alias Ecto.Changeset

  def suggest_price(%Request{} = request) do
    request
    |> preload_address()
    |> do_suggest_price()
    |> case do
      {:ok, suggested_price} ->
        request
        |> Request.changeset(%{
          suggested_price: suggested_price.listing_price_rounded,
          listing_price_rounded: suggested_price.listing_price_rounded,
          listing_price_error_q90_min: suggested_price.listing_price_error_q90_min,
          listing_price_error_q90_max: suggested_price.listing_price_error_q90_max,
          listing_price_per_sqr_meter: suggested_price.listing_price_per_sqr_meter,
          listing_average_price_per_sqr_meter: suggested_price.listing_average_price_per_sqr_meter
        })
        |> Repo.update()

      error ->
        error
    end
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
    |> format_output()
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

  defp format_output({:ok, suggested_price}), do: {:ok, suggested_price}

  defp format_output(response) do
    Sentry.capture_message("Error on priceteller response",
      extra: %{response: Kernel.inspect(response)}
    )

    response
  end

  defp preload_address(%Listing{} = listing), do: Repo.preload(listing, :address)

  defp preload_address(params), do: params

  def create_request(params, %{id: address_id}, user) do
    %Request{}
    |> Changeset.change(address_id: address_id)
    |> attach_user(user)
    |> Request.changeset(params)
    |> Repo.insert()
  end

  defp attach_user(changeset, %User{id: id}),
    do: Changeset.change(changeset, user_id: id)

  defp attach_user(changeset, _), do: changeset
end
