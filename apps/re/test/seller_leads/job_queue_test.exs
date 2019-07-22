defmodule Re.SellerLeads.JobQueueTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory

  alias Re.{
    SellerLead,
    SellerLeads.JobQueue,
    Repo
  }

  alias Ecto.Multi

  describe "price_suggestion_request" do
    test "process lead" do
      %{uuid: address_uuid} = address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user)

      %{uuid: uuid} =
        lead =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert seller.uuid
      assert seller.user_uuid == user_uuid
      assert seller.address_uuid == address_uuid
      assert seller.source == "WebSite"
      assert seller.complement == nil
      assert seller.type == lead.type
      assert seller.area == lead.area
      assert seller.maintenance_fee == lead.maintenance_fee
      assert seller.rooms == lead.rooms
      assert seller.bathrooms == lead.bathrooms
      assert seller.suites == lead.suites
      assert seller.garage_spots == lead.garage_spots
      assert seller.price == nil
      assert seller.suggested_price == lead.suggested_price
    end
  end
end
