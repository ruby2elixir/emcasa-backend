defmodule Re.AlikeTellerTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory
  import ExUnit.CaptureLog

  alias Re.{
    AlikeTeller,
    AlikeTeller.Server
  }

  setup do
    listing = insert(:listing)

    [rl1, rl2, rl3] = related1 = insert_list(3, :listing)
    [rl4, rl5, rl6] = related2 = insert_list(3, :listing)

    encoded_response1 =
      Jason.encode!(%{
        "data" => [
          %{
            "listing_uuid" => listing.uuid,
            "suggested_listing_uuids" => [rl1.uuid, rl2.uuid, rl3.uuid]
          }
        ],
        "prediction_datetime" => "2019-07-23 19:31:31.817877"
      })

    encoded_response2 =
      Jason.encode!(%{
        "data" => [
          %{
            "listing_uuid" => listing.uuid,
            "suggested_listing_uuids" => [rl4.uuid, rl5.uuid, rl6.uuid]
          }
        ],
        "prediction_datetime" => "2019-07-23 19:31:31.817877"
      })

    {:ok,
     encoded_response1: encoded_response1,
     encoded_response2: encoded_response2,
     listing: listing,
     related1: related1,
     related2: related2}
  end

  describe "handle_continue" do
    test "should load related listing uuids into ets", %{
      listing: listing,
      related1: [rl1, rl2, rl3],
      encoded_response1: encoded_response1
    } do
      mock(HTTPoison, :get, {:ok, %{status_code: 200, body: encoded_response1}})
      assert {:noreply, []} = Server.handle_continue(:load_aliketeller, [])

      assert {:ok, [rl1.uuid, rl2.uuid, rl3.uuid]} == AlikeTeller.get(listing.uuid)
    end

    @tag capture_log: true
    test "should throw exception on http error", %{listing: listing} do
      mock(HTTPoison, :get, {:error, %{reason: :timeout}})

      assert capture_log(fn ->
               Server.handle_continue(:load_aliketeller, [])
             end) =~ "Error loading aliketeller payload"

      assert {:error, :not_found} == AlikeTeller.get(listing.uuid)
    end

    test "should reload related listing when it's already there", %{
      listing: listing,
      related1: [rl1, rl2, rl3],
      related2: [rl4, rl5, rl6],
      encoded_response1: encoded_response1,
      encoded_response2: encoded_response2
    } do
      mock(HTTPoison, :get, {:ok, %{status_code: 200, body: encoded_response1}})
      assert {:noreply, []} = Server.handle_continue(:load_aliketeller, [])

      assert {:ok, [rl1.uuid, rl2.uuid, rl3.uuid]} == AlikeTeller.get(listing.uuid)

      mock(HTTPoison, :get, {:ok, %{status_code: 200, body: encoded_response2}})
      Server.handle_cast(:load_aliketeller, [])

      assert {:ok, [rl4.uuid, rl5.uuid, rl6.uuid]} == AlikeTeller.get(listing.uuid)
    end
  end
end
