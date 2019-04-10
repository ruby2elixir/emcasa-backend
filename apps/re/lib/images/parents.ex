defmodule Re.Images.Parents do
  @moduledoc """
  This module know how to to fetch and interact with image parents.
  """

  alias Re.{
    Developments,
    Listings,
  }

  def get_image_parent(images_and_inputs) do
    cond do
      unique_listing_parent?(images_and_inputs) -> get_listing_parent(images_and_inputs)
      unique_development_parent?(images_and_inputs) -> get_development_parent(images_and_inputs)
      true -> {:error, :distinct_parents}
    end
  end

  defp unique_listing_parent?([{:ok, %{listing_id: first_id}, _params} | images]) do
    parent_is_unique =
      Enum.all?(images, fn {:ok, %{listing_id: listing_id}, _} -> listing_id == first_id end)

    not is_nil(first_id) && parent_is_unique
  end

  defp unique_listing_parent?(_), do: false

  defp unique_development_parent?([{:ok, %{development_uuid: first_id}, _params} | images]) do
    parent_is_unique =
      Enum.all?(images, fn {:ok, %{development_uuid: development_uuid}, _} ->
        development_uuid == first_id
      end)

    not is_nil(first_id) && parent_is_unique
  end

  defp unique_development_parent?(_), do: false

  defp get_listing_parent([{:ok, %{listing_id: listing_id}, _} | _]), do: Listings.get(listing_id)

  defp get_development_parent([{:ok, %{development_uuid: development_uuid}, _} | _]),
    do: Developments.get(development_uuid)
end
