defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Re.Listings

  def update_listing(listing, []), do: {:ok, listing}

  def update_listing(listing, unit_prices_list) when is_nil(unit_prices_list),
    do: {:ok, listing}

  def update_listing(listing, unit_price_list) do
    min_price = Enum.min(unit_price_list)

    Listings.update_price(listing, min_price)
  end
end
