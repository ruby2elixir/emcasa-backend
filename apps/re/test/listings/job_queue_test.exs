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
            "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915,\"listing_price_error_q90_min\":25200.0,\"listing_price_error_q90_max\":28544.0,\"listing_price_per_sqr_meter\":560.0,\"listing_average_price_per_sqr_meter\":610.0}"
         }}
      )

      %{uuid: listing_uuid} = insert(:listing, address: build(:address))

      assert {:ok, %{update_suggested_price: listing}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "save_price_suggestion",
                 "uuid" => listing_uuid
               })

      assert listing = Repo.get_by(Listing, uuid: listing_uuid)
      assert listing.suggested_price == 26279
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

    @tag capture_log: true
    test "do not raise when parameters are invalid" do
      mock(HTTPoison, :post, {:error, %{error: "some error"}})

      %{uuid: listing_uuid} = insert(:listing, address: build(:address), area: 0)

      {:ok, _} =
        JobQueue.perform(Multi.new(), %{
          "type" => "save_price_suggestion",
          "uuid" => listing_uuid
        })

      refute Repo.one(JobQueue)
    end
  end
end
