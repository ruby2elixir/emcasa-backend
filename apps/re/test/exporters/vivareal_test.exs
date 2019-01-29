defmodule Re.Exporters.VivarealTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Exporters.Vivareal,
    Images,
    Listing,
    Listings.Queries,
    Repo
  }

  describe "build_xml/0" do
    test "export XML from listing" do
      images = [
        insert(:image, filename: "test1.jpg", description: "descr"),
        insert(:image, filename: "test2.jpg", description: "descr"),
        insert(:image, filename: "test3.jpg", description: "descr")
      ]

      %{id: id} =
        listing =
        insert(:listing,
          type: "Apartamento",
          address:
            build(:address,
              city: "Rio de Janeiro",
              state: "RJ",
              neighborhood: "Copacabana",
              street: "Avenida Atlântica",
              street_number: "55",
              postal_code: "11111-111",
              lat: -23.5531131,
              lng: -46.659864
            ),
          images: images,
          description: "descr",
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          inserted_at: ~N[2018-06-07 15:30:00.000000],
          updated_at: ~N[2018-06-07 15:30:00.000000],
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      expected_xml =
        "<Listing>" <>
          "<ListingId>#{id}</ListingId>" <>
          "<Title>Apartamento a venda em Rio de Janeiro</Title>" <>
          "<TransactionType>For Sale</TransactionType>" <>
          "<ListDate>2018-06-07T15:30:00</ListDate>" <>
          "<LastUpdateDate>2018-06-07T15:30:00</LastUpdateDate>" <>
          "<DetailViewUrl>http://localhost:3000/imoveis/#{id}</DetailViewUrl>" <>
          images_tags() <>
          details_tags() <>
          location_tags() <> contact_info_tags() <> "<Featured>false</Featured>" <> "</Listing>"

      assert expected_xml == listing |> Vivareal.build_xml() |> XmlBuilder.generate(format: :none)
    end

    test "export XML from listing with nil values" do
      images = [
        insert(:image, filename: "test1.jpg", description: "descr"),
        insert(:image, filename: "test2.jpg", description: "descr"),
        insert(:image, filename: "test3.jpg", description: "descr")
      ]

      %{id: id} =
        listing =
        insert(:listing,
          type: "Apartamento",
          address:
            build(:address,
              city: "Rio de Janeiro",
              state: "RJ",
              neighborhood: "Copacabana",
              street: "Avenida Atlântica",
              street_number: "55",
              postal_code: "11111-111",
              lat: -23.5531131,
              lng: -46.659864
            ),
          images: images,
          description: nil,
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          inserted_at: ~N[2018-06-07 15:30:00.000000],
          updated_at: ~N[2018-06-07 15:30:00.000000],
          maintenance_fee: nil,
          property_tax: nil
        )

      expected_xml =
        "<Listing>" <>
          "<ListingId>#{id}</ListingId>" <>
          "<Title>Apartamento a venda em Rio de Janeiro</Title>" <>
          "<TransactionType>For Sale</TransactionType>" <>
          "<ListDate>2018-06-07T15:30:00</ListDate>" <>
          "<LastUpdateDate>2018-06-07T15:30:00</LastUpdateDate>" <>
          "<DetailViewUrl>http://localhost:3000/imoveis/#{id}</DetailViewUrl>" <>
          images_tags() <>
          details_tags_nils() <>
          location_tags() <> contact_info_tags() <> "<Featured>false</Featured>" <> "</Listing>"

      assert expected_xml == listing |> Vivareal.build_xml() |> XmlBuilder.generate(format: :none)
    end

    test "export XML with nil bathrooms/rooms" do
      images = [
        insert(:image, filename: "test1.jpg", description: "descr"),
        insert(:image, filename: "test2.jpg", description: "descr"),
        insert(:image, filename: "test3.jpg", description: "descr")
      ]

      %{id: id} =
        listing =
        insert(:listing,
          type: "Apartamento",
          address:
            build(:address,
              city: "Rio de Janeiro",
              state: "RJ",
              neighborhood: "Copacabana",
              street: "Avenida Atlântica",
              street_number: "55",
              postal_code: "11111-111",
              lat: -23.5531131,
              lng: -46.659864
            ),
          images: images,
          description: "descr",
          area: 50,
          price: 1_000_000,
          rooms: nil,
          bathrooms: nil,
          inserted_at: ~N[2018-06-07 15:30:00.000000],
          updated_at: ~N[2018-06-07 15:30:00.000000],
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      expected_xml =
        "<Listing>" <>
          "<ListingId>#{id}</ListingId>" <>
          "<Title>Apartamento a venda em Rio de Janeiro</Title>" <>
          "<TransactionType>For Sale</TransactionType>" <>
          "<ListDate>2018-06-07T15:30:00</ListDate>" <>
          "<LastUpdateDate>2018-06-07T15:30:00</LastUpdateDate>" <>
          "<DetailViewUrl>http://localhost:3000/imoveis/#{id}</DetailViewUrl>" <>
          images_tags() <>
          rooms_nil_details_tags() <>
          location_tags() <> contact_info_tags() <> "<Featured>false</Featured>" <> "</Listing>"

      assert expected_xml == listing |> Vivareal.build_xml() |> XmlBuilder.generate(format: :none)
    end

    test "export listing with highlights" do
      images = [
        insert(:image, filename: "test1.jpg", description: "descr"),
        insert(:image, filename: "test2.jpg", description: "descr"),
        insert(:image, filename: "test3.jpg", description: "descr")
      ]

      %{id: id} =
        listing =
        insert(:listing,
          type: "Apartamento",
          address:
            build(:address,
              city: "Rio de Janeiro",
              state: "RJ",
              neighborhood: "Copacabana",
              street: "Avenida Atlântica",
              street_number: "55",
              postal_code: "11111-111",
              lat: -23.5531131,
              lng: -46.659864
            ),
          images: images,
          vivareal_highlight: true,
          description: "descr",
          area: 50,
          price: 1_000_000,
          rooms: nil,
          bathrooms: nil,
          inserted_at: ~N[2018-06-07 15:30:00.000000],
          updated_at: ~N[2018-06-07 15:30:00.000000],
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      highlight_ids = [id]

      expected_xml =
        "<Listing>" <>
          "<ListingId>#{id}</ListingId>" <>
          "<Title>Apartamento a venda em Rio de Janeiro</Title>" <>
          "<TransactionType>For Sale</TransactionType>" <>
          "<ListDate>2018-06-07T15:30:00</ListDate>" <>
          "<LastUpdateDate>2018-06-07T15:30:00</LastUpdateDate>" <>
          "<DetailViewUrl>http://localhost:3000/imoveis/#{id}</DetailViewUrl>" <>
          images_tags() <>
          rooms_nil_details_tags() <>
          location_tags() <> contact_info_tags() <> "<Featured>true</Featured>" <> "</Listing>"

      assert expected_xml ==
               listing
               |> Vivareal.build_xml(%{highlight_ids: highlight_ids})
               |> XmlBuilder.generate(format: :none)
    end
  end

  describe "export_listings_xml/1" do
    @preload [:address, images: Images.Queries.listing_preload()]

    test "should export listings wrapped" do
      image = insert(:image, filename: "test1.jpg", description: "descr")
      listing = insert(:listing, images: [image])

      listings =
        Listing
        |> Queries.preload_relations(@preload)
        |> Repo.all()

      assert ~s|<?xml version="1.0" encoding="UTF-8"?><ListingDataFeed | <>
               ~s|xmlns="http://www.vivareal.com/schemas/1.0/VRSync" | <>
               ~s|xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" | <>
               ~s|xsi:schemaLocation="http://www.vivareal.com/schemas/1.0/VRSync  | <>
               ~s|http://xml.vivareal.com/vrsync.xsd">| <>
               ~s|<Header>| <>
               ~s|<Provider>EmCasa</Provider>| <>
               ~s|<Email>rodrigo.nonose@emcasa.com</Email>| <>
               ~s|<ContactName>Rodrigo Nonose</ContactName>| <>
               ~s|</Header>| <>
               ~s|<Listings><Listing><ListingId>#{listing.id}</ListingId><Featured>false</Featured></Listing></Listings></ListingDataFeed>| ==
               Vivareal.export_listings_xml(listings, %{attributes: ~w(id)a})
    end

    test "should not export listings without images" do
      insert(:listing)

      listings =
        Listing
        |> Queries.preload_relations(@preload)
        |> Repo.all()

      assert ~s|<?xml version="1.0" encoding="UTF-8"?><ListingDataFeed xmlns="http://www.vivareal.com/schemas/1.0/VRSync" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vivareal.com/schemas/1.0/VRSync  http://xml.vivareal.com/vrsync.xsd"><Header><Provider>EmCasa</Provider><Email>rodrigo.nonose@emcasa.com</Email><ContactName>Rodrigo Nonose</ContactName></Header><Listings/></ListingDataFeed>| ==
               Vivareal.export_listings_xml(listings, ~w(images)a)
    end
  end

  defp images_tags do
    "<Media>" <>
      ~s|<Item caption="descr" medium="image">https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test1.jpg</Item>| <>
      ~s|<Item caption="descr" medium="image">https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test2.jpg</Item>| <>
      ~s|<Item caption="descr" medium="image">https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test3.jpg</Item>| <>
      "</Media>"
  end

  defp details_tags do
    "<Details>" <>
      "<PropertyType>Residential / Apartment</PropertyType>" <>
      "<Description>&lt;![CDATA[descr]]&gt;</Description>" <>
      "<ListPrice>1000000</ListPrice>" <>
      "<LivingArea unit=\"square metres\">50</LivingArea>" <>
      "<PropertyAdministrationFee currency=\"BRL\">1000</PropertyAdministrationFee>" <>
      "<YearlyTax currency=\"BRL\">1000</YearlyTax>" <>
      "<Bedrooms>2</Bedrooms>" <> "<Bathrooms>2</Bathrooms>" <> "</Details>"
  end

  defp details_tags_nils do
    "<Details>" <>
      "<PropertyType>Residential / Apartment</PropertyType>" <>
      "<Description>&lt;![CDATA[]]&gt;</Description>" <>
      "<ListPrice>1000000</ListPrice>" <>
      "<LivingArea unit=\"square metres\">50</LivingArea>" <>
      "<Bedrooms>2</Bedrooms>" <> "<Bathrooms>2</Bathrooms>" <> "</Details>"
  end

  defp rooms_nil_details_tags do
    "<Details>" <>
      "<PropertyType>Residential / Apartment</PropertyType>" <>
      "<Description>&lt;![CDATA[descr]]&gt;</Description>" <>
      "<ListPrice>1000000</ListPrice>" <>
      "<LivingArea unit=\"square metres\">50</LivingArea>" <>
      "<PropertyAdministrationFee currency=\"BRL\">1000</PropertyAdministrationFee>" <>
      "<YearlyTax currency=\"BRL\">1000</YearlyTax>" <>
      "<Bedrooms>0</Bedrooms>" <> "<Bathrooms>0</Bathrooms>" <> "</Details>"
  end

  defp location_tags do
    "<Location displayAddress=\"Neighborhood\">" <>
      "<Country abbreviation=\"BR\">Brasil</Country>" <>
      "<State abbreviation=\"RJ\">Rio de Janeiro</State>" <>
      "<City>Rio de Janeiro</City>" <>
      "<Neighborhood>Copacabana</Neighborhood>" <>
      "<Address>Avenida Atlântica</Address>" <>
      "<StreetNumber>55</StreetNumber>" <>
      "<PostalCode>11111-111</PostalCode>" <>
      "<Latitude>-23.5531131</Latitude>" <> "<Longitude>-46.659864</Longitude>" <> "</Location>"
  end

  defp contact_info_tags do
    "<ContactInfo>" <>
      "<Name>EmCasa</Name>" <>
      "<Email>contato@emcasa.com</Email>" <>
      "<Website>https://www.emcasa.com</Website>" <>
      "<Logo>https://s3.amazonaws.com/emcasa-ui/logo/logo.png</Logo>" <>
      "<OfficeName>EmCasa</OfficeName>" <>
      "<Telephone>(21) 3195-6541</Telephone>" <> "</ContactInfo>"
  end
end
