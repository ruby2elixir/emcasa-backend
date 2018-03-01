defmodule Re.ImagesTest do
  use Re.ModelCase

  alias Re.{
    Image,
    Images
  }

  import Re.Factory

  describe "update_per_listing/2" do
    test "should do nothing when there's no change" do
      listing1 = insert(:listing)
      listing2 = insert(:listing)
      [%{id: id1}, %{id: id2}, %{id: id3}] = insert_list(3, :image, listing_id: listing1.id)
      %{id: id4} = insert(:image, listing_id: listing2.id, position: 0)

      images_params = [
        %{"id" => id1, "position" => 6},
        %{"id" => id2, "position" => 7},
        %{"id" => id3, "position" => 8},
        %{"id" => id4, "position" => 9}
      ]

      assert :ok == Images.update_per_listing(listing1, images_params)
      assert Repo.get(Image, id1).position == 6
      assert Repo.get(Image, id2).position == 7
      assert Repo.get(Image, id3).position == 8
      assert Repo.get(Image, id4).position == 0
    end
  end
end
