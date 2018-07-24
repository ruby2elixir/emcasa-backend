defmodule Re.InterestsTest do
  use Re.ModelCase

  alias Re.{
    PriceSuggestions.Request,
    Interests,
    Repo
  }

  import Re.Factory

  describe "request_price_suggestion/2" do
    test "should store price suggestion request" do
      insert(
        :factors,
        street: "street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 2,
        garage_spots: 2
      }

      assert {:ok, %{id: request_id}, {:ok, 1565.654}} =
               Interests.request_price_suggestion(params, nil)

      assert Repo.get(Request, request_id)
    end

    test "should store price suggestion request with user attached" do
      insert(
        :factors,
        street: "street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      user = insert(:user)

      address_params = %{
        street: "street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 2,
        garage_spots: 2
      }

      assert {:ok, %{id: request_id}, {:ok, 1565.654}} =
               Interests.request_price_suggestion(params, user)

      assert Repo.get(Request, request_id)
    end

    test "should store price suggestion request when street is not covered" do
      insert(
        :factors,
        street: "street",
        intercept: 10.10,
        rooms: 123.321,
        area: 321.123,
        bathrooms: 111.222,
        garage_spots: 222.111
      )

      address_params = %{
        street: "not covered street",
        street_number: "street_number",
        neighborhood: "neighborhood",
        city: "city",
        state: "ST",
        postal_code: "postal_code",
        lat: 10.10,
        lng: 10.10
      }

      params = %{
        address: address_params,
        name: "name",
        email: "email@emcasa.com",
        rooms: 2,
        bathrooms: 2,
        area: 2,
        garage_spots: 2
      }

      assert {:ok, %{id: request_id}, {:error, :street_not_covered}} =
               Interests.request_price_suggestion(params, nil)

      assert Repo.get(Request, request_id)
    end
  end
end
