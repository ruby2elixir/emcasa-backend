defmodule Re.PriceTellerTest do
  use Re.ModelCase

  import Mockery

  alias Re.PriceTeller

  @valid_payload %{
    type: "APARTMENT",
    zip_code: "03346010",
    street_number: "10",
    area: 79,
    bathrooms: 1,
    bedrooms: 3,
    suites: 1,
    parking: 2,
    condo_fee: 300,
    lat: -23.559797,
    lng: -46.571548
  }

  @invalid_payload %{
    type: "apê",
    zip_code: "003346010",
    street_number: nil,
    area: 13,
    bathrooms: -1,
    bedrooms: 25,
    suites: -1,
    parking: 25,
    condo_fee: 11_000,
    lat: nil,
    lng: nil
  }

  describe "ask/1" do
    test "with valid params" do
      mock(
        HTTPoison,
        :post,
        {:ok,
         %{
           body:
             "{\"sale_price_rounded\":575000.0,\"sale_price\":575910.45,\"listing_price_rounded\":635000.0,\"listing_price\":632868.63}"
         }}
      )

      assert {:ok,
              %{
                listing_price: 632_868.63,
                listing_price_rounded: 635_000.0,
                sale_price: 575_910.45,
                sale_price_rounded: 575_000.0
              }} == PriceTeller.ask(@valid_payload)
    end

    @tag capture_log: true
    test "with invalid params" do
      assert {:error, changeset} = PriceTeller.ask(@invalid_payload)

      assert Keyword.get(changeset.errors, :type) ==
               {"is invalid",
                [
                  validation: :inclusion,
                  enum: ~w(APARTMENT CONDOMINIUM KITNET HOME TWO_STORY_HOUSE FLAT PENTHOUSE)
                ]}

      assert Keyword.get(changeset.errors, :zip_code) ==
               {"should be %{count} character(s)",
                [count: 8, validation: :length, kind: :is, type: :string]}

      assert Keyword.get(changeset.errors, :area) ==
               {"must be greater than %{number}",
                [validation: :number, kind: :greater_than, number: 15]}

      assert Keyword.get(changeset.errors, :bathrooms) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :bedrooms) ==
               {"must be less than %{number}",
                [validation: :number, kind: :less_than, number: 20]}

      assert Keyword.get(changeset.errors, :suites) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :parking) ==
               {"must be less than %{number}",
                [validation: :number, kind: :less_than, number: 20]}

      assert Keyword.get(changeset.errors, :condo_fee) ==
               {"must be less than %{number}",
                [validation: :number, kind: :less_than, number: 10_000]}
    end
  end
end
