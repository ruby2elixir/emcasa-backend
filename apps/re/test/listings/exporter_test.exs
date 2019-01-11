defmodule Re.Listings.ExporterTest do
  use Re.ModelCase

  alias Re.Listings.Exporter

  import Re.Factory

  describe "exportable/1" do
    test "return if both state and city slugs exists" do
      sao_paulo = insert(:address, city_slug: "sao-paulo", state_slug: "sp")

      rio_de_janeiro = insert(:address, city_slug: "rio-de-janeiro", state_slug: "rj")

      listing_1 = insert(:listing, address_id: sao_paulo.id)
      insert(:listing, address_id: rio_de_janeiro.id)

      assert [listing_1] =
               Exporter.exportable(
                 %{
                   state_slug: sao_paulo.state_slug,
                   city_slug: sao_paulo.city_slug
                 },
                 %{}
               )
    end

    test "should not return if state slug doesn't match" do
      sao_paulo = insert(:address, city_slug: "sao-paulo", state_slug: "sp")

      insert(:listing, address_id: sao_paulo.id)

      assert [] = Exporter.exportable(%{state_slug: "rj", city_slug: sao_paulo.city_slug}, %{})
    end

    test "should not return if city slug doesn't match" do
      sao_paulo = insert(:address, city_slug: "sao-paulo", state_slug: "sp")

      insert(:listing, address_id: sao_paulo.id)

      assert [] =
               Exporter.exportable(
                 %{
                   state_slug: sao_paulo.state_slug,
                   city_slug: "rio-de-janeiro"
                 },
                 %{}
               )
    end

    test "should accept page_size" do
      sao_paulo = insert(:address, city_slug: "sao-paulo", state_slug: "sp")

      %{id: id_1} = insert(:listing, address_id: sao_paulo.id)
      insert(:listing, address_id: sao_paulo.id)

      result =
        Exporter.exportable(
          %{state_slug: sao_paulo.state_slug, city_slug: sao_paulo.city_slug},
          %{page_size: 1}
        )

      assert [%{id: ^id_1}] = result
    end

    test "should accept offset" do
      sao_paulo = insert(:address, city_slug: "sao-paulo", state_slug: "sp")

      insert(:listing, address_id: sao_paulo.id)
      %{id: id_2} = insert(:listing, address_id: sao_paulo.id)

      result =
        Exporter.exportable(
          %{state_slug: sao_paulo.state_slug, city_slug: sao_paulo.city_slug},
          %{offset: 1}
        )

      assert [%{id: ^id_2}] = result
    end
  end
end