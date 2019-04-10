defmodule Re.Images.ParentsTest do
  use Re.ModelCase

  alias Re.Images.Parents

  import Re.Factory

  describe "check_same_parent/1" do
    test "should return parent when images are from same listing" do
      listing = insert(:listing)
      assert {:ok, listing} ==
               Parents.get_image_parent([
                 %{listing_id: listing.id},
                 %{listing_id: listing.id}
               ])
    end

    test "should return parent when images are from same development" do
      development = insert(:development)
      assert {:ok, development} ==
                Parents.get_image_parent([
                  %{development_uuid: development.uuid},
                  %{development_uuid: development.uuid}
                ])
    end

    test "should return error when images are from distinct listing" do
      assert {:error, :distinct_parents} ==
                Parents.get_image_parent([
                  %{listing_id: 1},
                  %{listing_id: 2}
                ])
    end

    test "should return error when images are from distinct development" do
      assert {:error, :distinct_parents} ==
                Parents.get_image_parent([
                  %{development_uuid: "aa"},
                  %{development_uuid: "bb"}
                ])
    end
  end
end

