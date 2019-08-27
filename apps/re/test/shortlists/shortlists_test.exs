defmodule Re.ShortlistsTest do
  use Re.ModelCase

  import Re.Factory

  import Mockery

  alias Re.Shortlists

  @http_client Application.get_env(:re, :http)

  describe "get_or_create/2" do
    test "get shortlist if already exists" do
      listing = insert(:listing)
      %{opportunity_id: opportunity_id} = shortlist = insert(:shortlist, listings: [listing])

      {:ok, fetched_shortlist} = Shortlists.get_or_create(opportunity_id)
      fetched_shortlist = fetched_shortlist |> Re.Repo.preload(:listings)

      assert shortlist.uuid == fetched_shortlist.uuid
      assert shortlist.opportunity_id == fetched_shortlist.opportunity_id
      assert shortlist.listings == fetched_shortlist.listings
    end

    test "create shortlist if doesn't exists" do
      %{uuid: listing_uuid} = listing = insert(:listing)

      mock_request(HTTPoison, :post, "{}")
      mock_request(HTTPoison, :get, "[\"#{listing_uuid}\"]")

      assert {:ok, fetched_shortlist} = Shortlists.get_or_create("0x01")
      assert fetched_shortlist.uuid
      assert fetched_shortlist.opportunity_id == "0x01"
      assert fetched_shortlist.listings == [listing]
    end
  end

  def mock_request(client, type, body) do
    mock(
      client,
      type,
      {:ok,
       %{
         status_code: 200,
         body: body
       }}
    )
  end
end
