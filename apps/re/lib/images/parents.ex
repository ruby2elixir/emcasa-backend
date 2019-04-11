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
    case Enum.uniq_by(images, fn image -> Map.get(image, :listing_id) end) do
      [%{listing_id: _}] -> Listings.get(listing_id)
      _ -> {:error, :distinct_parents}
    end
  end

  def get_parent_from_image_list([%{development_uuid: development_uuid} | _] = images)
      when not is_nil(development_uuid) do
    case Enum.uniq_by(images, fn image -> Map.get(image, :development_uuid) end) do
      [%{development_uuid: _}] -> Developments.get(development_uuid)
      _ -> {:error, :distinct_parents}
    end
  end
end
