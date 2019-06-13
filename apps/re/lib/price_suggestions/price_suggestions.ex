defmodule Re.PriceSuggestions do
  @moduledoc """
  Module for suggesting prices according to stored factors
  """
  NimbleCSV.define(PriceSuggestionsParser, separator: ",", escape: "\"")

  alias Re.{
    Listing,
    PriceSuggestions.Factors,
    PriceSuggestions.Request,
    Repo,
    User
  }

  alias ReIntegrations.PriceTeller

  import Ecto.Query

  alias Ecto.Changeset

  def suggest_price(%Request{} = request) do
    request
    |> preload_address()
    |> do_suggest_price()
    |> case do
      {:ok, suggested_price} ->
        request
        |> Request.changeset(%{suggested_price: suggested_price})
        |> Repo.update()

      error ->
        error
    end
  end

  def suggest_price(params) do
    params
    |> preload_address()
    |> do_suggest_price()
  end

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

  defp format_output({:ok, %{listing_price_rounded: listing_price_rounded}}),
    do: {:ok, listing_price_rounded}

  defp format_output(response) do
    Sentry.capture_message("Error on priceteller response",
      extra: %{response: Kernel.inspect(response)}
    )

    response
  end

  defp preload_address(%Listing{} = listing), do: Repo.preload(listing, :address)

  defp preload_address(params), do: params

  def save_factors(file) do
    file
    |> PriceSuggestionsParser.parse_string()
    |> Stream.map(&csv_to_map/1)
    |> Enum.each(&persist/1)
  end

  defp csv_to_map([state, city, street, intercept, area, bathrooms, rooms, garage_spots, r2]) do
    %{
      state: :binary.copy(state),
      city: :binary.copy(city),
      street: :binary.copy(street),
      intercept: intercept |> Float.parse() |> elem(0),
      area: area |> Float.parse() |> elem(0),
      bathrooms: bathrooms |> Float.parse() |> elem(0),
      rooms: rooms |> Float.parse() |> elem(0),
      garage_spots: garage_spots |> Float.parse() |> elem(0),
      r2: r2 |> Float.parse() |> elem(0)
    }
  end

  defp persist(%{state: state, city: city, street: street} = line) do
    case Repo.get_by(Factors, state: state, city: city, street: street) do
      nil ->
        %Factors{}
        |> Factors.changeset(line)
        |> Repo.insert()

      factor ->
        factor
        |> Factors.changeset(line)
        |> Repo.update()
    end
  end

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

  def generate_price_comparison do
    to_write =
      Listing
      |> where([l], l.status == "active")
      |> preload(:address)
      |> Repo.all()
      |> Enum.map(&compare_prices/1)
      |> Enum.filter(fn
        {:error, _} -> false
        _other -> true
      end)
      |> Enum.map(&encode/1)
      |> Enum.join("\n")

    File.write("export.txt", to_write)
  end

  defp compare_prices(listing) do
    case suggest_price(listing) do
      {:error, :street_not_covered} ->
        {:error, :street_not_covered}

      suggested_price ->
        %{listing_id: listing.id, actual_price: listing.price, suggested_price: suggested_price}
    end
  end

  defp encode(%{
         listing_id: listing_id,
         actual_price: actual_price,
         suggested_price: suggested_price
       }) do
    "ID: #{listing_id}, Preço atual: #{actual_price}, Preço Sugerido: #{suggested_price}"
  end
end
