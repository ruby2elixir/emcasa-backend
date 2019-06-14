defmodule Re.PriceSuggestionsTest do
  use Re.ModelCase

  doctest Re.PriceSuggestions

  import Re.Factory
  import Mockery
  import ExUnit.CaptureLog

  alias Re.{
    Listing,
    PriceSuggestions,
    PriceSuggestions.Factors
  }

  describe "save_factors/1" do
    test "should save csv into database" do
      {:ok, file} = File.read("test/support/factors.csv")

      PriceSuggestions.save_factors(file)

      assert [
               %{
                 state: "NY",
                 city: "New York City",
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 state: "NY",
                 city: "New York City",
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 state: "NY",
                 city: "New York City",
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 state: "NY",
                 city: "New York City",
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               }
             ] = Repo.all(Factors)
    end

    test "should replace existing records" do
      {:ok, file} = File.read("test/support/factors.csv")

      insert(
        :factors,
        state: "NY",
        city: "New York City",
        street: "Manhattan Street 1",
        intercept: -39.23068199,
        area: 23.0332,
        bathrooms: 8.74290,
        rooms: -57.5033,
        garage_spots: 96.982,
        r2: 0.0928
      )

      insert(
        :factors,
        state: "NY",
        city: "New York City",
        street: "Manhattan Street 2",
        intercept: -39.23068199,
        area: 23.0332,
        bathrooms: 8.74290,
        rooms: -57.5033,
        garage_spots: 96.982,
        r2: 0.0928
      )

      insert(
        :factors,
        state: "NY",
        city: "New York City",
        street: "Manhattan Street 3",
        intercept: -39.23068199,
        area: 23.0332,
        bathrooms: 8.74290,
        rooms: -57.5033,
        garage_spots: 96.982,
        r2: 0.0928
      )

      insert(
        :factors,
        state: "NY",
        city: "New York City",
        street: "Manhattan Street 4",
        intercept: -39.23068199,
        area: 23.0332,
        bathrooms: 8.74290,
        rooms: -57.5033,
        garage_spots: 96.982,
        r2: 0.0928
      )

      PriceSuggestions.save_factors(file)

      assert [
               %{
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               }
             ] = Repo.all(Factors)
    end
  end

  describe "suggest_price/1" do
    test "should suggest price for listing and persist it" do
      %{uuid: uuid} =
        listing =
        insert(
          :listing,
          rooms: 2,
          area: 80,
          address: build(:address, state: "MS", city: "Mah City", street: "Mah Street"),
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
          address: build(:address, state: "MS", city: "Mah City", street: "Mah Street"),
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
                          address:
                            build(:address, state: "MS", city: "Mah City", street: "Mah Street"),
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
  end
end
