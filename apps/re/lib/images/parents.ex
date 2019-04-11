defmodule Re.Images.Parents do
  @moduledoc """
  This module know how to fetch and interact with image parents.
  """

  alias Re.{
    Developments,
    Listings
  }

  def get_parent_from_image_list([%{listing_id: listing_id} | _] = images)
      when not is_nil(listing_id) do
    case unique_listing_parent?(images) do
      true -> get_listing_parent(images)
      false -> {:error, :distinct_parents}
    end
  end

  def get_parent_from_image_list([%{development_uuid: development_uuid} | _] = images)
      when not is_nil(development_uuid) do
    case unique_development_parent?(images) do
      true -> get_development_parent(images)
      false -> {:error, :distinct_parents}
    end
  end

  defp unique_listing_parent?(images) do
    case Enum.uniq_by(images, fn image -> Map.get(image, :listing_id) end) do
      [%{listing_id: _}] -> true
      _ -> false
    end
  end

  defp unique_development_parent?(images) do
    case Enum.uniq_by(images, fn image -> Map.get(image, :development_uuid) end) do
      [%{development_uuid: _}] -> true
      _ -> false
    end
  end

  defp get_listing_parent([%{listing_id: listing_id} | _]), do: Listings.get(listing_id)

  defp get_development_parent([%{development_uuid: development_uuid} | _]),
    do: Developments.get(development_uuid)
end
