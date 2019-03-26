defmodule Re.Listings.Units.Propagator do
  @moduledoc """
  Context module for listing units interactions, usually changes in units would
  be replicated/reflected in listings until we migrate replicated structure to units.
  """

  alias Re.Listings

  def update_listing(
        %{price: listing_price} = listing,
        %{price: unit_price}
      )
      when is_nil(listing_price) or unit_price < listing_price do
    Listings.update_price(listing, unit_price)
  end

  def update_listing(listing, _new_unit), do: {:ok, listing}
end
