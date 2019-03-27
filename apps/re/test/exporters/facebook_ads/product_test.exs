defmodule Re.Exporters.FacebookAds.ProductTest do
  use Re.ModelCase

  alias Re.{
    Exporters.FacebookAds,
    Image,
    Address,
    Listing
  }

  @frontend_url Application.get_env(:re_integrations, :frontend_url)
  @image_url "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385"

  describe "build_node/2" do
    test "export XML including listing first image" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        rooms: 4,
        bathrooms: 4,
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
        matterport_code: "mY123",
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
        "<entry>" <>
          "<id><![CDATA[7004578]]></id>" <>
          "<link><![CDATA[#{@frontend_url}/imoveis/7004578]]></link>" <>
          "<title><![CDATA[Apartamento a venda em São Paulo]]></title>" <>
          "<availability><![CDATA[in stock]]></availability>" <>
          "<condition><![CDATA[new]]></condition>" <>
          "<brand><![CDATA[EmCasa]]></brand>" <>
          "<description><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></description>" <>
          "<price><![CDATA[800 BRL]]></price>" <>
          "<custom_label_0><![CDATA[Apartamento]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Rua do Ipiranga, Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[4]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[4]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <>
          "<image_link><![CDATA[#{@image_url}/living_room.png]]></image_link>" <> "</entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(FacebookAds.Product.merge_default_options(%{}))
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
        "<entry>" <>
          "<id><![CDATA[7004578]]></id>" <>
          "<link><![CDATA[#{@frontend_url}/imoveis/7004578]]></link>" <>
          "<title><![CDATA[Apartamento a venda em São Paulo]]></title>" <>
          "<availability><![CDATA[in stock]]></availability>" <>
          "<condition><![CDATA[new]]></condition>" <>
          "<brand><![CDATA[EmCasa]]></brand>" <>
          "<description><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></description>" <>
          "<price><![CDATA[800 BRL]]></price>" <>
          "<custom_label_0><![CDATA[Apartamento]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Rua do Ipiranga, Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[4]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[4]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <> "<image_link/>" <> "</entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(FacebookAds.Product.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end

    test "export XML without rooms/bathroms from listing" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        rooms: nil,
        bathrooms: nil,
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
        "<entry>" <>
          "<id><![CDATA[7004578]]></id>" <>
          "<link><![CDATA[#{@frontend_url}/imoveis/7004578]]></link>" <>
          "<title><![CDATA[Apartamento a venda em São Paulo]]></title>" <>
          "<availability><![CDATA[in stock]]></availability>" <>
          "<condition><![CDATA[new]]></condition>" <>
          "<brand><![CDATA[EmCasa]]></brand>" <>
          "<description><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></description>" <>
          "<price><![CDATA[800 BRL]]></price>" <>
          "<custom_label_0><![CDATA[Apartamento]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Rua do Ipiranga, Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[0]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[0]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <> "<image_link/>" <> "</entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(FacebookAds.Product.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end
  end

  describe "export_listing/1" do
    test "export listing with proper root node" do
      expected_xml =
        ~s|<?xml version="1.0" encoding="UTF-8"?>| <>
          "<feed xmlns=\"http://www.w3.org/2005/Atom\">" <>
          "<entry><id><![CDATA[1]]></id></entry></feed>"

      generated_xml =
        FacebookAds.Product.export_listings_xml([%Listing{id: 1}], %{attributes: [:id]})

      assert expected_xml == generated_xml
    end
  end
end
