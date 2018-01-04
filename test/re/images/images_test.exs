defmodule Re.ImagesTest do
  use Re.ModelCase

  alias Re.{
    Images
  }

  import Re.Factory

  describe "update_per_listing/2" do
    test "should do nothing when there's no change" do
      listing1 = insert(:listing)
      listing2 = insert(:listing)
      images = insert_list(3, :image, listing_id: listing1.id)
      image_outside_listing = insert(:image, listing_id: listing2.id)
      images = [image_outside_listing | images]

      images_paramas =
        images
        |> Enum.map(&Map.from_struct/1)
        |> Enum.map(&(Map.delete(&1, :__meta__)))
        |> Enum.map(&stringify_keys/1)

      assert {:error, :bad_request} == Images.update_per_listing(listing1, images_paramas)
    end
  end

  defp stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
