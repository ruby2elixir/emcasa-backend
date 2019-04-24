defmodule Re.OwnerContactsTest do
  use Re.ModelCase

  alias Re.OwnerContacts

  import Re.Factory

  describe "all/0" do
    test "get all owners contacts available" do
      %{uuid: uuid_1} = insert(:owner_contact)
      %{uuid: uuid_2} = insert(:owner_contact)

      result = Enum.map(OwnerContacts.all(), & &1.uuid)

      assert Enum.member?(result, uuid_1)
      assert Enum.member?(result, uuid_2)
    end
  end

  describe "get/1" do
    test "get existing owner contact by uuid" do
      owner_contact = insert(:owner_contact)

      assert {:ok, fetched_owner_contact} = OwnerContacts.get(owner_contact.uuid)

      assert owner_contact == fetched_owner_contact
    end

    test "error when contact owner doesn't exist" do
      insert(:owner_contact)

      inexistent_uuid = UUID.uuid4()

      assert {:error, :not_found} = OwnerContacts.get(inexistent_uuid)
    end
  end

  describe "get_by_phone/1" do
    test "get existing owner contact by phone" do
      owner_contact = insert(:owner_contact)

      assert {:ok, fetched_owner_contact} = OwnerContacts.get_by_phone(owner_contact.phone)

      assert owner_contact == fetched_owner_contact
    end

    test "error when contact owner doesn't exist" do
      insert(:owner_contact, phone: "+5511876543210")

      inexistent_phone = "+5511987654321"

      assert {:error, :not_found} = OwnerContacts.get_by_phone(inexistent_phone)
    end
  end

  describe "insert/1" do
    test "should insert an owner contact" do
      params = %{name: "Jon Snow", phone: "+5511987654321", email: "jon@snow.com"}

      assert {:ok, inserted_owner_contact} = OwnerContacts.insert(params)

      assert inserted_owner_contact.uuid != nil
      assert inserted_owner_contact.name_slug == "jon-snow"
      assert inserted_owner_contact.name == params.name
      assert inserted_owner_contact.phone == params.phone
      assert inserted_owner_contact.email == params.email
    end

    test "should upsert existing owner contact" do
      owner_contact =
        insert(:owner_contact,
          name: "Jon Snow",
          name_slug: "jon-snow",
          phone: "+5511987654321",
          email: nil
        )

      params = %{name: "JON SNOW", phone: "+5511987654321", email: "jon@snow.com"}

      assert {:ok, updated_owner_contact} = OwnerContacts.insert(params)

      assert updated_owner_contact.uuid == owner_contact.uuid
      assert updated_owner_contact.name_slug == owner_contact.name_slug
      assert updated_owner_contact.phone == owner_contact.phone
      assert updated_owner_contact.name == params.name
      assert updated_owner_contact.email == params.email
    end
  end

  describe "update/2" do
    test "should update an existing owner contact" do
      owner_contact =
        insert(:owner_contact,
          name: "Jon Snow",
          name_slug: "jon-snow",
          phone: "+5511987654321",
          email: "jon@snow.com"
        )

      params = %{name: "Joan Snow", phone: "+5511876543210", email: "joan@snow.com"}

      assert {:ok, updated_owner_contact} = OwnerContacts.update(owner_contact, params)

      assert updated_owner_contact.uuid == owner_contact.uuid
      assert updated_owner_contact.name == params.name
      assert updated_owner_contact.phone == params.phone
      assert updated_owner_contact.email == params.email
      assert updated_owner_contact.name_slug == "joan-snow"
    end
  end
end
