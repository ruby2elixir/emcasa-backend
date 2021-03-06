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

  describe "update_images/1" do
    test "should error when input is invalid" do
      [image1, image2, image3] = insert_list(3, :image)

      assert {:ok, [_, %Ecto.Changeset{}, _]} =
               Images.update_images([
                 {:ok, image1, %{position: 1, description: "waow1"}},
                 {:ok, image2, %{position: false, description: "waow2"}},
                 {:ok, image3, %{position: 3, description: "waow3"}}
               ])
    end
  end

  describe "insert/2" do
    @insert_params %{filename: "test.jpg"}

    test "should insert listing image active" do
      listing =
        insert(:listing)
        |> Re.Repo.preload([:images])

      {:ok, inserted_image} = Images.insert(@insert_params, listing)
      assert inserted_image.is_active == true
      assert inserted_image.listing == listing
    end

    test "should insert development image active" do
      development =
        insert(:development)
        |> Re.Repo.preload([:images])

      {:ok, inserted_image} = Images.insert(@insert_params, development)
      assert inserted_image.is_active == true
      assert inserted_image.development == development
    end
  end
end
