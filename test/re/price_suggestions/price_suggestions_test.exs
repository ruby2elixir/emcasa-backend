defmodule Re.PriceSuggestionsTest do
  use Re.ModelCase

  doctest Re.PriceSuggestions

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
  end
end
