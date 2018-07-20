defmodule Re.PriceSuggestionsTest do
  use Re.ModelCase

  doctest Re.PriceSuggestions

  import Re.Factory

  alias Re.{
    PriceSuggestions,
    PriceSuggestions.Factors
  }

  describe "save_factors/1" do
    test "should save csv into database" do
      {:ok, file} = File.read("test/support/factors.csv")

      PriceSuggestions.save_factors(file)

      assert [
               %{
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
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
        street: "Manhattan Street 1",
        intercept: -399.23068199,
        area: 237.0332,
        bathrooms: 83.74290,
        rooms: -578.5033,
        garage_spots: 962.982,
        r2: 0.09128
      )

      insert(
        :factors,
        street: "Manhattan Street 2",
        intercept: -399.23068199,
        area: 237.0332,
        bathrooms: 83.74290,
        rooms: -578.5033,
        garage_spots: 962.982,
        r2: 0.09128
      )

      insert(
        :factors,
        street: "Manhattan Street 3",
        intercept: -399.23068199,
        area: 237.0332,
        bathrooms: 83.74290,
        rooms: -578.5033,
        garage_spots: 962.982,
        r2: 0.09128
      )

      insert(
        :factors,
        street: "Manhattan Street 4",
        intercept: -399.23068199,
        area: 237.0332,
        bathrooms: 83.74290,
        rooms: -578.5033,
        garage_spots: 962.982,
        r2: 0.09128
      )

      PriceSuggestions.save_factors(file)

      assert [
               %{
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
                 street: "Manhattan Street" <> _,
                 intercept: -399.23068199,
                 area: 237.0332,
                 bathrooms: 83.74290,
                 rooms: -578.5033,
                 garage_spots: 962.982,
                 r2: 0.09128
               },
               %{
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

    test "should suggest price for listing" do
      listing =
        insert(
          :listing,
          rooms: 2,
          area: 80,
          address: build(:address, street: "Mah Street"),
          garage_spots: 1,
          bathrooms: 1
        )

      insert(
        :factors,
        street: "Mah Street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      assert 26_279.915 == PriceSuggestions.suggest_price(listing)
    end
  end

  describe "suggest_price/1" do
    test "should suggest for nil values" do
      insert(:factors, street: "Mah Street", intercept: 10.10, rooms: 123.321, area: 321.123, bathrooms: 111.222, garage_spots: 222.111)

      assert 10.10 == PriceSuggestions.suggest_price(%{address: %{street: "Mah Street"}, rooms: nil, area: nil, bathrooms: nil, garage_spots: nil})
    end
  end
end
