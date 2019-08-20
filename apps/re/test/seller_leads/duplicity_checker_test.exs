defmodule Re.SellerLead.DuplicityChecker do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Listing,
    SellerLead,
    SellerLeads.DuplicityChecker
  }

  setup do
    {:ok, address: insert(:address)}
  end

  describe "duplicated?" do
    test "should be false when the address doesn't exists for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "Apto. 201")

      refute DuplicityChecker.duplicated?(address, "Apartamento 401")
    end

    test "should be true when the address and the complement is nil for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: nil)

      assert DuplicityChecker.duplicated?(address, nil)
    end

    test "should be true when the address has the exactly same complement for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "100")

      assert DuplicityChecker.duplicated?(address, "100")
    end

    test "should be true when the seller lead address has a complement with letters for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "apto 100")

      assert DuplicityChecker.duplicated?(address, "100")
    end

    test "should be true when the passed address has a complement with letters for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "100")

      assert DuplicityChecker.duplicated?(address, "apto 100")
    end

    test "should be true when the address has a similar complement with letters and multiple groups for seller lead" do
      address = insert(:address)
      insert(:seller_lead, address: address, complement: "Bloco 3 - Apto 200")

      assert DuplicityChecker.duplicated?(address, "Apto. 200 - Bloco 3")
    end

    test "should be true when the passed address has a similar complement for a publicated listing" do
      address = insert(:address)
      insert(:listing, address: address, complement: "Bloco 3 - Apto 200")

      assert DuplicityChecker.duplicated?(address, "Apto. 200 - Bloco 3")
    end

    test "should be false when the passed address is the same address but a different complement as a publicated listing" do
      address = insert(:address)
      insert(:listing, address: address, complement: "Bloco 3 - Apto 320")

      refute DuplicityChecker.duplicated?(address, "Apto. 200 - Bloco 3")
    end
  end

  describe "duplicated_entities" do
    test "should return an empty list when the address doesn't exists for seller lead", %{
      address: address
    } do
      insert(:seller_lead, address: address, complement: "Apto. 201")

      assert [] == DuplicityChecker.duplicated_entities(address, "Apartamento 401")
    end

    test "should return a list with one seller lead when the address and the complement is nil matches with one seller lead in the base",
         %{address: address} do
      seller_lead = insert(:seller_lead, address: address, complement: nil)

      assert [%{type: SellerLead, uuid: seller_lead.uuid}] ==
               DuplicityChecker.duplicated_entities(address, nil)
    end

    test "should return a list with one listing uuid when the address and the complement is nil matches with one listing in the base",
         %{address: address} do
      listing = insert(:listing, address: address, complement: nil)

      assert [%{type: Listing, uuid: listing.uuid}] ==
               DuplicityChecker.duplicated_entities(address, nil)
    end

    test "should return a list with one listing and one seller lead when the address and the complement is nil matches with one listing  and one seller in the base",
         %{address: address} do
      listing = insert(:listing, address: address, complement: nil)
      seller_lead = insert(:seller_lead, address: address, complement: nil)

      assert [
               %{type: SellerLead, uuid: seller_lead.uuid},
               %{type: Listing, uuid: listing.uuid}
             ] == DuplicityChecker.duplicated_entities(address, nil)
    end

    test "should return a list with one seller lead uuid when the address has the exactly same complement for seller lead",
         %{address: address} do
      seller_lead = insert(:seller_lead, address: address, complement: "100")

      assert [%{type: SellerLead, uuid: seller_lead.uuid}] ==
               DuplicityChecker.duplicated_entities(address, "100")
    end

    test "should return a list with one seller lead when the seller lead address has a complement with letters for seller lead",
         %{address: address} do
      seller_lead = insert(:seller_lead, address: address, complement: "apto 100")

      assert [%{type: SellerLead, uuid: seller_lead.uuid}] ==
               DuplicityChecker.duplicated_entities(address, "100")
    end

    test "should return a map with one seller lead when the passed address has a complement with letters for seller lead",
         %{address: address} do
      seller_lead = insert(:seller_lead, address: address, complement: "100")

      assert [%{type: SellerLead, uuid: seller_lead.uuid}] ==
               DuplicityChecker.duplicated_entities(address, "apto 100")
    end

    test "should return a list with one seller lead when the address has a similar complement with letters and multiple groups for seller lead",
         %{address: address} do
      seller_lead = insert(:seller_lead, address: address, complement: "Bloco 3 - Apto 200")

      assert [
               %{type: SellerLead, uuid: seller_lead.uuid}
             ] == DuplicityChecker.duplicated_entities(address, "Apto. 200 - Bloco 3")
    end

    test "should return a list with one listing when the passed address has a similar complement for a publicated listing",
         %{address: address} do
      listing = insert(:listing, address: address, complement: "Bloco 3 - Apto 200")

      assert [%{type: Listing, uuid: listing.uuid}] ==
               DuplicityChecker.duplicated_entities(address, "Apto. 200 - Bloco 3")
    end

    test "should return an empty list when the passed address is the same address but a different complement as a publicated listing",
         %{address: address} do
      insert(:listing, address: address, complement: "Bloco 3 - Apto 320")

      assert [] == DuplicityChecker.duplicated_entities(address, "Apto. 200 - Bloco 3")
    end
  end
end
