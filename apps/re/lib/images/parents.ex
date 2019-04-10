defmodule Re.Images.Parents do
  @moduledoc """
  This module know how to fetch and interact with image parents.
  """

  alias Re.{
    Developments,
    Listings
  }

  def get_image_parent(images) do
    cond do
      unique_listing_parent?(images) -> get_listing_parent(images)
      unique_development_parent?(images) -> get_development_parent(images)
      true -> {:error, :distinct_parents}
    end
  end

  defp unique_listing_parent?([%{listing_id: first_id} | images]) do
    parent_is_unique =
      Enum.all?(images, fn %{listing_id: listing_id} -> listing_id == first_id end)

    not is_nil(first_id) && parent_is_unique
  end

  defp unique_listing_parent?(_), do: false

  defp unique_development_parent?([%{development_uuid: first_id} | images]) do
    parent_is_unique =
      Enum.all?(images, fn %{development_uuid: development_uuid} ->
        development_uuid == first_id
      end)

    not is_nil(first_id) && parent_is_unique
  end

  defp unique_development_parent?(_), do: false

  defp get_listing_parent([%{listing_id: listing_id} | _]), do: Listings.get(listing_id)

  defp get_development_parent([%{development_uuid: development_uuid} | _]),
    do: Developments.get(development_uuid)
end
