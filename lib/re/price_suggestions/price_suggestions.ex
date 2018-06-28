defmodule Re.PriceSuggestions do
  NimbleCSV.define(PriceSuggestionsParser, separator: ",", escape: "\"")

  alias Re.{
    PriceSuggestions.Factors,
    Repo
  }

  def suggest_price(listing) do
    listing
    |> get_factor_by_street()
    |> do_suggest_price(listing)
  end

  defp get_factor_by_street(%{address: %{street: street}}), do: Repo.get_by(Factors, street: street)

  defp do_suggest_price(nil, _), do: {:error, :street_not_covered}

  defp do_suggest_price(factors, listing) do
    factors.intercept + listing.area * factors.area + listing.bathrooms * factors.bathrooms +
      listing.rooms * factors.rooms + listing.garage_spots * factors.garage_spots
  end

  def save_factors(file) do
    file
    |> PriceSuggestionsParser.parse_string()
    |> Stream.map(&csv_to_map/1)
    |> Enum.each(&persist/1)
  end

  defp csv_to_map([street, intercept, area, bathrooms, rooms, garage_spots, r2]) do
    %{
      street: :binary.copy(street),
      intercept: Float.parse(intercept) |> elem(0),
      area: Float.parse(area) |> elem(0),
      bathrooms: Float.parse(bathrooms) |> elem(0),
      rooms: Float.parse(rooms) |> elem(0),
      garage_spots: Float.parse(garage_spots) |> elem(0),
      r2: Float.parse(r2) |> elem(0)
    }
  end

  defp persist(line) do
    %Factors{}
    |> Factors.changeset(line)
    |> Repo.insert()
  end
end
