defmodule Re.SellerLeads.BrokerTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.SellerLeads.Broker

  @valid_attributes %{
    owner_telephone: "+559999999999",
    owner_name: "Xurupita",
    type: "Apartamento"
  }

  @invalid_attributes %{
    type: "asdasdjhka"
  }

  describe "changeset" do
    test "should be valid" do
      user = insert(:user, type: "partner_broker")
      owner = insert(:user)
      address = insert(:address)

      attr = @valid_attributes
              |> Map.merge(%{broker_uuid: user.uuid})
              |> Map.merge(%{address_uuid: address.uuid})
              |> Map.merge(%{owner_uuid: owner.uuid})

      changeset = Broker.changeset(%Broker{}, attr)

      assert changeset.valid?
    end

    test "should be invalid" do
      changeset = Broker.changeset(%Broker{}, @invalid_attributes)
      refute changeset.valid?

      assert Keyword.get(changeset.errors, :type) ==
               {"is invalid", [validation: :inclusion, enum: ~w(Apartamento Casa Cobertura)]}

      assert Keyword.get(changeset.errors, :owner_uuid) ==
               {"can't be blank", [validation: :required]}

      assert Keyword.get(changeset.errors, :address_uuid) ==
               {"can't be blank", [validation: :required]}

      assert Keyword.get(changeset.errors, :broker_uuid) ==
               {"can't be blank", [validation: :required]}
    end
  end
end
