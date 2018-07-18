defmodule Re.PriceSuggestions do
  @moduledoc """
  Module for suggesting prices according to stored factors
  """
  NimbleCSV.define(PriceSuggestionsParser, separator: ",", escape: "\"")

  alias Re.{
    Listing,
    PriceSuggestions.Factors,
    Repo
  }

  def suggest_price(listing) do
    listing
    |> preload_if_struct()
    |> get_factor_by_street()
    |> do_suggest_price(listing)
  end

  defp get_factor_by_street(%{address: %{street: street}}),
    do: Repo.get_by(Factors, street: street)

  defp do_suggest_price(nil, _), do: {:error, :street_not_covered}

  defp do_suggest_price(factors, listing) do
    factors.intercept + listing.area * factors.area + listing.bathrooms * factors.bathrooms +
      listing.rooms * factors.rooms + listing.garage_spots * factors.garage_spots
  end

  defp preload_if_struct(%Listing{} = listing), do: Repo.preload(listing, :address)

  defp preload_if_struct(listing), do: listing

  def save_factors(file) do
    file
    |> PriceSuggestionsParser.parse_string()
    |> Stream.map(&csv_to_map/1)
    |> Enum.each(&persist/1)
  end

  defp csv_to_map([street, intercept, area, bathrooms, rooms, garage_spots, r2]) do
    %{
      street: :binary.copy(street),
      intercept: intercept |> Float.parse() |> elem(0),
      area: area |> Float.parse() |> elem(0),
      bathrooms: bathrooms |> Float.parse() |> elem(0),
      rooms: rooms |> Float.parse() |> elem(0),
      garage_spots: garage_spots |> Float.parse() |> elem(0),
      r2: r2 |> Float.parse() |> elem(0)
    }
  end

  defp persist(%{street: street} = line) do
    case Repo.get_by(Factors, street: street) do
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
end
