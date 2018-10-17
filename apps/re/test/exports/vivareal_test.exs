defmodule Re.Exporters.VivarealTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.Exporters.Vivareal

  test "export XML from listing" do
    images = [
      insert(:image, filename: "test1.jpg", description: "descr"),
      insert(:image, filename: "test2.jpg", description: "descr"),
      insert(:image, filename: "test3.jpg", description: "descr")
    ]
    %{id: id} = listing = insert(:listing, type: "Apartamento", address: build(:address, city: "Rio de Janeiro", state: "RJ", neighborhood: "Copacabana"), images: images, description: "descr", area: 50, price: 1_000_000, rooms: 2, bathrooms: 2)
    expected_xml = "<Listing>" <>
      "<ListingId>#{id}</ListingId>" <>
      "<Title>Apartamento a venda em Rio de Janeiro</Title>" <>
      "<TransactionType>For Sale</TransactionType>" <>
      "<Featured>false</Featured>" <>
      images_tags() <>
      details_tags() <>
      location_tags() <>
      contact_info_tags() <>
      "</Listing>"
    assert expected_xml == Vivareal.export_xml(listing)
  end

  defp images_tags do
    "<Media>" <>
    "<Item caption=\"descr\" medium=\"image\">https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test1.jpg</Item>" <>
    "<Item caption=\"descr\" medium=\"image\">https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test2.jpg</Item>" <>
    "<Item caption=\"descr\" medium=\"image\">https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test3.jpg</Item>" <>
    "</Media>"
  end

  defp details_tags do
    "<Details>" <>
    "<PropertyType>Residential / Apartment</PropertyType>" <>
    "<Description>&lt;![CDATA[descr]]&gt;</Description>" <>
    "<ListPrice>1000000</ListPrice>" <>
    "<LivingArea unit=\"square metres\">50</LivingArea>" <>
    "<Bedrooms>2</Bedrooms>" <>
    "<Bathrooms>2</Bathrooms>" <>
    "</Details>"
  end

  defp location_tags do
    "<Location displayAddress=\"Neighborhood\">" <>
    "<Country abbreviation=\"BR\">Brasil</Country>" <>
    "<State abbreviation=\"RJ\">Rio de Janeiro</State>" <>
    "<City>Rio de Janeiro</City>" <>
    "<Neighborhood>Copacabana</Neighborhood>" <>
    "</Location>"
  end

  defp contact_info_tags do
    "<ContactInfo>" <>
    "<Name>EmCasa</Name>" <>
    "<Email>contato@emcasa.com</Email>" <>
    "</ContactInfo>"
  end

end
