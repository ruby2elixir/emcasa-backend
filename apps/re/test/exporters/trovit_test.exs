defmodule Re.Exporters.TrovitTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Exporters.Trovit,
    Image,
    Address,
    Listing
  }

  @frontend_url Application.get_env(:re_integrations, :frontend_url)
  @image_url "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385"

  describe "build_node/2" do
    test "export XML with images from listing" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        rooms: 4,
        bathrooms: 4,
        garage_spots: 4,
        description:
          "Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço",
        address: %Address{
          street: "Rua do Ipiranga",
          street_number: 20,
          neighborhood: "Ipiranga",
          city: "São Paulo",
          state: "SP",
          postal_code: "04732-192",
          lat: 51.496401,
          lng: -0.179
        },
        images: [
          %Image{
            filename: "living_room.png",
            description: "Living room"
          },
          %Image{
            filename: "suite_1.png",
            description: nil
          }
        ]
      }

      expected_xml =
        "<ad>" <>
          "<id><![CDATA[7004578]]></id>" <>
          "<url><![CDATA[#{@frontend_url}/imoveis/7004578]]></url>" <>
          "<title><![CDATA[Apartamento a venda em São Paulo]]></title>" <>
          "<type><![CDATA[For Sale]]></type>" <>
          "<content><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></content>" <>
          "<price><![CDATA[800]]></price>" <>
          "<property_type><![CDATA[Apartamento]]></property_type>" <>
          "<floor_area><![CDATA[300]]></floor_area>" <>
          "<rooms><![CDATA[4]]></rooms>" <>
          "<bathrooms><![CDATA[4]]></bathrooms>" <>
          "<parking><![CDATA[4]]></parking>" <>
          "<region><![CDATA[São Paulo]]></region>" <>
          "<city><![CDATA[São Paulo]]></city>" <>
          "<city_area><![CDATA[Ipiranga]]></city_area>" <>
          "<address><![CDATA[Rua do Ipiranga, 20]]></address>" <>
          "<postcode><![CDATA[04732-192]]></postcode>" <>
          "<latitude><![CDATA[51.496401]]></latitude>" <>
          "<longitude><![CDATA[-0.179]]></longitude>" <>
          "<by_owner><![CDATA[-]]></by_owner>" <>
          "<agency><![CDATA[-]]></agency>" <>
          "<pictures>" <>
          "<picture>" <>
          "<picture_url><![CDATA[#{@image_url}/living_room.png]]></picture_url>" <>
          "<picture_title><![CDATA[Living room]]></picture_title>" <>
          "</picture>" <>
          "<picture>" <>
          "<picture_url><![CDATA[#{@image_url}/suite_1.png]]></picture_url>" <>
          "<picture_title><![CDATA[]]></picture_title>" <>
          "</picture>" <>
          "</pictures>" <>
          "</ad>"

      generated_xml =
        listing
        |> Trovit.build_node(Trovit.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end

    test "export XML without images from listing" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        rooms: 4,
        bathrooms: 4,
        garage_spots: 4,
        description:
          "Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço",
        address: %Address{
          street: "Rua do Ipiranga",
          street_number: 20,
          neighborhood: "Ipiranga",
          city: "São Paulo",
          state: "SP",
          postal_code: "04732-192",
          lat: 51.496401,
          lng: -0.179
        },
        images: []
      }

      expected_xml =
        "<ad>" <>
          "<id><![CDATA[7004578]]></id>" <>
          "<url><![CDATA[#{@frontend_url}/imoveis/7004578]]></url>" <>
          "<title><![CDATA[Apartamento a venda em São Paulo]]></title>" <>
          "<type><![CDATA[For Sale]]></type>" <>
          "<content><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></content>" <>
          "<price><![CDATA[800]]></price>" <>
          "<property_type><![CDATA[Apartamento]]></property_type>" <>
          "<floor_area><![CDATA[300]]></floor_area>" <>
          "<rooms><![CDATA[4]]></rooms>" <>
          "<bathrooms><![CDATA[4]]></bathrooms>" <>
          "<parking><![CDATA[4]]></parking>" <>
          "<region><![CDATA[São Paulo]]></region>" <>
          "<city><![CDATA[São Paulo]]></city>" <>
          "<city_area><![CDATA[Ipiranga]]></city_area>" <>
          "<address><![CDATA[Rua do Ipiranga, 20]]></address>" <>
          "<postcode><![CDATA[04732-192]]></postcode>" <>
          "<latitude><![CDATA[51.496401]]></latitude>" <>
          "<longitude><![CDATA[-0.179]]></longitude>" <>
          "<by_owner><![CDATA[-]]></by_owner>" <>
          "<agency><![CDATA[-]]></agency>" <>
          "<pictures/>" <>
          "</ad>"

      generated_xml =
        listing
        |> Trovit.build_node(Trovit.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end

    test "export XML without rooms/bathroms/garage spots from listing" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        rooms: nil,
        bathrooms: nil,
        garage_spots: nil,
        description:
          "Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço",
        address: %Address{
          street: "Rua do Ipiranga",
          street_number: 20,
          neighborhood: "Ipiranga",
          city: "São Paulo",
          state: "SP",
          postal_code: "04732-192",
          lat: 51.496401,
          lng: -0.179
        },
        images: []
      }

      expected_xml =
        "<ad>" <>
          "<id><![CDATA[7004578]]></id>" <>
          "<url><![CDATA[#{@frontend_url}/imoveis/7004578]]></url>" <>
          "<title><![CDATA[Apartamento a venda em São Paulo]]></title>" <>
          "<type><![CDATA[For Sale]]></type>" <>
          "<content><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></content>" <>
          "<price><![CDATA[800]]></price>" <>
          "<property_type><![CDATA[Apartamento]]></property_type>" <>
          "<floor_area><![CDATA[300]]></floor_area>" <>
          "<rooms><![CDATA[0]]></rooms>" <>
          "<bathrooms><![CDATA[0]]></bathrooms>" <>
          "<parking><![CDATA[0]]></parking>" <>
          "<region><![CDATA[São Paulo]]></region>" <>
          "<city><![CDATA[São Paulo]]></city>" <>
          "<city_area><![CDATA[Ipiranga]]></city_area>" <>
          "<address><![CDATA[Rua do Ipiranga, 20]]></address>" <>
          "<postcode><![CDATA[04732-192]]></postcode>" <>
          "<latitude><![CDATA[51.496401]]></latitude>" <>
          "<longitude><![CDATA[-0.179]]></longitude>" <>
          "<by_owner><![CDATA[-]]></by_owner>" <>
          "<agency><![CDATA[-]]></agency>" <>
          "<pictures/>" <>
          "</ad>"

      generated_xml =
        listing
        |> Trovit.build_node(Trovit.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end
  end

  describe "export_listing/1" do
    test "export listing with proper root node" do
      expected_xml =
        ~s|<?xml version="1.0" encoding="UTF-8"?>| <>
          "<trovit><ad><id><![CDATA[1]]></id></ad></trovit>"

      generated_xml = Trovit.export_listings_xml([%Listing{id: 1}], %{attributes: [:id]})

      assert expected_xml == generated_xml
    end
  end
end
