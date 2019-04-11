defmodule Re.Images.Parents do
  @moduledoc """
  This module know how to fetch and interact with image parents.
  """

  alias Re.{
    Developments,
    Listings
  }

  def get_parent_from_image_list(images) do
    cond do
      unique_listing_parent?(images) -> get_listing_parent(images)
      unique_development_parent?(images) -> get_development_parent(images)
      true -> {:error, :distinct_parents}
    end
  end

  defp unique_listing_parent?(images) do
    unique_images_by_listing_id =
      Enum.uniq_by(images, fn image -> Map.get(image, :listing_id) end)

    case unique_images_by_listing_id do
      [%{listing_id: nil}] -> false
      [%{listing_id: _}] -> true
      _ -> false
    end
  end

  defp unique_development_parent?(images) do
    unique_images_by_development_uuid =
      Enum.uniq_by(images, fn image -> Map.get(image, :development_uuid) end)

    case unique_images_by_development_uuid do
      [%{development_uuid: nil}] -> false
      [%{development_uuid: _}] -> true
      _ -> false
    end
  end

  defp get_listing_parent([%{listing_id: listing_id} | _]), do: Listings.get(listing_id)

  defp get_development_parent([%{development_uuid: development_uuid} | _]),
    do: Developments.get(development_uuid)
end
