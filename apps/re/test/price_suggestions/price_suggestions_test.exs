defmodule Re.PriceSuggestionsTest do
  use Re.ModelCase

  doctest Re.PriceSuggestions

  import Re.Factory
  import Mockery
  import ExUnit.CaptureLog

  alias Re.{
    Listing,
    PriceSuggestions
  }

  describe "suggest_price/1" do
    test "should suggest price for listing and persist it" do
      %{uuid: uuid} =
        listing =
        insert(
          :listing,
          rooms: 2,
          area: 80,
          address: build(:address),
          garage_spots: 1,
          bathrooms: 1,
          suggested_price: nil
        )

      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915}"
         }}
      )

      assert {:ok, 26_279.0} == PriceSuggestions.suggest_price(listing)
      listing = Repo.get_by(Listing, uuid: uuid)
      assert listing.suggested_price == 26_279.0
    end

    test "should update suggest price for listing when there's one" do
      %{uuid: uuid} =
        listing =
        insert(
          :listing,
          rooms: 2,
          area: 80,
          address: build(:address),
          garage_spots: 1,
          bathrooms: 1,
          suggested_price: 1000.0
        )

      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":24195.0,\"sale_price\":24195.791,\"listing_price_rounded\":26279.0,\"listing_price\":26279.915}"
         }}
      )

      assert {:ok, 26_279.0} == PriceSuggestions.suggest_price(listing)
      listing = Repo.get_by(Listing, uuid: uuid)
      assert listing.suggested_price == 26_279.0
    end

    test "should not suggest for nil values" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":8.0,\"sale_price\":8.8,\"listing_price_rounded\":10.0,\"listing_price\":10.10}"
         }}
      )

      assert capture_log(fn ->
               assert {:error, changeset} =
                        PriceSuggestions.suggest_price(%{
                          address: build(:address),
                          rooms: nil,
                          area: nil,
                          bathrooms: nil,
                          garage_spots: nil,
                          type: "invalid",
                          maintenance_fee: nil,
                          suites: nil
                        })

               assert Keyword.get(changeset.errors, :type) ==
                        {"is invalid",
                         [
                           validation: :inclusion,
                           enum:
                             ~w(APARTMENT CONDOMINIUM KITNET HOME TWO_STORY_HOUSE FLAT PENTHOUSE)
                         ]}

               assert Keyword.get(changeset.errors, :area) ==
                        {"can't be blank", [validation: :required]}

               assert Keyword.get(changeset.errors, :bathrooms) ==
                        {"can't be blank", [validation: :required]}

               assert Keyword.get(changeset.errors, :bedrooms) ==
                        {"can't be blank", [validation: :required]}

               assert Keyword.get(changeset.errors, :suites) ==
                        {"can't be blank", [validation: :required]}

               assert Keyword.get(changeset.errors, :parking) ==
                        {"can't be blank", [validation: :required]}
             end) =~
               ":invalid_input in priceteller"
    end

    @tag capture_log: true
    test "should handle timeout error" do
      %{uuid: uuid} =
        listing =
        insert(
          :listing,
          rooms: 2,
          area: 80,
          address: build(:address),
          garage_spots: 1,
          bathrooms: 1,
          suggested_price: nil
        )

      mock(HTTPoison, :post, {:error, %{reason: :timeout}})

      assert {:error, %{reason: :timeout}} == PriceSuggestions.suggest_price(listing)
      listing = Repo.get_by(Listing, uuid: uuid)
      refute listing.suggested_price
    end
  end
end
