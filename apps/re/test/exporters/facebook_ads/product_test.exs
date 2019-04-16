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
  @max_additional_images 20

  describe "build_node/2" do
    test "export XML with images from listing" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        price_per_area: 800 / 300,
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
          },
          %Image{
            filename: "bath_1.png",
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
          "<product_type><![CDATA[Apartamento]]></product_type>" <>
          "<custom_label_0><![CDATA[Rua do Ipiranga]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[4]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[4]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <>
          "<sale_price><![CDATA[2.67 BRL]]></sale_price>" <>
          "<image_link><![CDATA[#{@image_url}/living_room.png]]></image_link>" <>
          "<additional_image_link><![CDATA[#{@image_url}/suite_1.png,#{@image_url}/bath_1.png]]></additional_image_link>" <>
          "</entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(FacebookAds.Product.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end

    test "export XML of a listing with a single image" do
      listing = %Listing{
        id: 7_004_578,
        price: 800,
        type: "Apartamento",
        area: 300,
        price_per_area: 800 / 300,
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
          "<product_type><![CDATA[Apartamento]]></product_type>" <>
          "<custom_label_0><![CDATA[Rua do Ipiranga]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[4]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[4]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <>
          "<sale_price><![CDATA[2.67 BRL]]></sale_price>" <>
          "<image_link><![CDATA[#{@image_url}/living_room.png]]></image_link>" <>
          "<additional_image_link><![CDATA[]]></additional_image_link>" <> "</entry>"

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
        price_per_area: 800 / 300,
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
          "<product_type><![CDATA[Apartamento]]></product_type>" <>
          "<custom_label_0><![CDATA[Rua do Ipiranga]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[4]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[4]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <>
          "<sale_price><![CDATA[2.67 BRL]]></sale_price>" <>
          "<image_link/><additional_image_link/>" <> "</entry>"

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
        price_per_area: 800 / 300,
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
          "<product_type><![CDATA[Apartamento]]></product_type>" <>
          "<custom_label_0><![CDATA[Rua do Ipiranga]]></custom_label_0>" <>
          "<custom_label_1><![CDATA[Ipiranga]]></custom_label_1>" <>
          "<custom_label_2><![CDATA[0]]></custom_label_2>" <>
          "<custom_label_3><![CDATA[0]]></custom_label_3>" <>
          "<custom_label_4><![CDATA[300]]></custom_label_4>" <>
          "<sale_price><![CDATA[2.67 BRL]]></sale_price>" <>
          "<image_link/><additional_image_link/>" <> "</entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(FacebookAds.Product.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end

    test "should export sale_price when price_area is nil" do
      listing = %Listing{
        price_per_area: nil
      }

      expected_xml = "<entry><sale_price/></entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(%{attributes: [:price_per_area]})
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end

    test "should export sale_price as decimal" do
      listing = %Listing{
        price_per_area: 850_000 / 300
      }

      expected_xml = "<entry><sale_price><![CDATA[2833.33 BRL]]></sale_price></entry>"

      generated_xml =
        listing
        |> FacebookAds.Product.build_node(%{attributes: [:price_per_area]})
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end
  end

  describe "build_additional_image_node/1" do
    test "should not exceed max number of images" do
      images = Enum.map(1..30, fn x -> %{filename: "#{x}.png"} end)
      {_, _, urls} = FacebookAds.Product.build_additional_image_node(images)
      assert length(String.split(urls, ",")) == @max_additional_images
    end

    test "should slice first image" do
      images = Enum.map(1..5, fn x -> %{filename: "#{x}.png"} end)
      {_, _, urls} = FacebookAds.Product.build_additional_image_node(images)
      images_urls = String.split(urls, ",")
      assert Enum.at(images_urls, 0) == "#{@image_url}/2.png"
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

    test "should not export listings without images" do
      expected_xml =
        ~s|<?xml version="1.0" encoding="UTF-8"?>| <>
          "<feed xmlns=\"http://www.w3.org/2005/Atom\"/>"

      generated_xml =
        FacebookAds.Product.export_listings_xml([%Listing{id: 1, images: []}], %{
          attributes: [:id, :images]
        })

      assert expected_xml == generated_xml
    end
  end
end
