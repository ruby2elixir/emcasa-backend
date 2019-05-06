defmodule Re.SellerLeads.SiteTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.SellerLeads.Site

  @valid_attributes %{
    complement: "100",
    type: "Apartamento",
    maintenance_fee: 100.00,
    suites: 2,
    price: 800_000
  }

  @invalid_attributes %{
    type: "asdasdjhka",
    maintenance_fee: -15.00,
    suites: -1,
    price: -100
  }

  describe "changeset" do
    test "should be valid" do
      price_suggestion_request = insert(:price_suggestion_request)

      attrs = Map.put(@valid_attributes, :price_request_id, price_suggestion_request.id)

      changeset = Site.changeset(%Site{}, attrs)
      assert changeset.valid?
    end

    test "should be invalid" do
      changeset = Site.changeset(%Site{}, @invalid_attributes)
      refute changeset.valid?

      assert Keyword.get(changeset.errors, :type) ==
               {"should be one of: [Apartamento Casa Cobertura]", [validation: :inclusion]}

      assert Keyword.get(changeset.errors, :maintenance_fee) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :suites) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :price) ==
               {"must be greater than or equal to %{number}",
                [validation: :number, kind: :greater_than_or_equal_to, number: 0]}

      assert Keyword.get(changeset.errors, :price_request_id) ==
               {"can't be blank", [validation: :required]}
    end
  end
end
