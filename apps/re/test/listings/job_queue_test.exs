defmodule Re.Listings.JobQueueTest do
  @moduledoc false
  use Re.ModelCase

  import Re.Factory

  import Mockery

  alias Re.{
    Listing,
    Listings.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "perform/2" do
    test "persist suggested price" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":575000.0,\"sale_price\":575910.45,\"listing_price_rounded\":635000.0,\"listing_price\":632868.63}"
         }}
      )

      %{uuid: listing_uuid} = insert(:listing, address: build(:address))

      assert {:ok, %{update_suggested_price: listing}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "save_price_suggestion",
                 "uuid" => listing_uuid
               })

      assert listing = Repo.get_by(Listing, uuid: listing_uuid)
      assert listing.suggested_price == 635_000
    end

    @tag capture_log: true
    test "do not run multi when there's a fetch error" do
      mock(HTTPoison, :post, {:error, %{error: "some error"}})

      %{uuid: listing_uuid} = insert(:listing, address: build(:address))

      assert_raise RuntimeError, fn ->
        JobQueue.perform(Multi.new(), %{
          "type" => "save_price_suggestion",
          "uuid" => listing_uuid
        })
      end
    end
  end
end
