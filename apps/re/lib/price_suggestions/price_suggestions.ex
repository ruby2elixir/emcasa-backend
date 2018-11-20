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

  import Ecto.Query

  alias Ecto.Changeset

  def suggest_price(listing) do
    listing
    |> preload_if_struct()
    |> get_factor_by_address()
    |> do_suggest_price(listing)
  end

  defp get_factor_by_address(%{address: %{state: state, city: city, street: street}}),
    do: Repo.get_by(Factors, state: state, city: city, street: street)

  defp do_suggest_price(nil, _), do: {:error, :street_not_covered}

  defp do_suggest_price(factors, listing) do
    {:ok,
     factors.intercept + (listing.area || 0) * factors.area +
       (listing.bathrooms || 0) * factors.bathrooms + (listing.rooms || 0) * factors.rooms +
       (listing.garage_spots || 0) * factors.garage_spots}
  end

  defp preload_if_struct(%Listing{} = listing), do: Repo.preload(listing, :address)

  defp preload_if_struct(listing), do: listing

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
      |> where([l], l.is_active == true)
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
