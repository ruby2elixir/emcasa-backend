defmodule Re.Exporters.ImovelwebTest do
  use Re.ModelCase

  alias Re.{
    Exporters.Imovelweb,
    Image,
    Address,
    Listing
  }

  @image_url "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385"
  @tour_url "https://my.matterport.com"

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
        matterport_code: "mY123",
        images: [
          %Image{
            filename: "living_room.png",
            description: "Living room",
            position: 1
          },
          %Image{
            filename: "suite_1.png",
            description: nil,
            position: 2
          }
        ]
      }

      expected_xml =
        "<Imovel>" <>
          "<CodigoCentralVendas></CodigoCentralVendas>" <>
          "<CodigoImovel>7004578</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Padrão</SubTipoImovel>" <>
          "<TituloImovel>Apartamento a venda em São Paulo</TituloImovel>" <>
          "<Observacao><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></Observacao>" <>
          "<Modelo>SIMPLES</Modelo>" <>
          "<UF>SP</UF>" <>
          "<Cidade><![CDATA[São Paulo]]></Cidade>" <>
          "<Bairro><![CDATA[Ipiranga]]></Bairro>" <>
          "<Endereco><![CDATA[Rua do Ipiranga]]></Endereco>" <>
          "<Numero>20</Numero>" <>
          "<CEP>04732-192</CEP>" <>
          "<DivulgarEndereco>APROX</DivulgarEndereco>" <>
          "<Latitude>51.496401</Latitude>" <>
          "<Longitude>-0.179</Longitude>" <>
          "<VisualizarMapa>1</VisualizarMapa>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<AreaUtil>300</AreaUtil>" <>
          "<PrecoVenda>800</PrecoVenda>" <>
          "<PrecoCondominio/>" <>
          "<QtdDormitorios>4</QtdDormitorios>" <>
          "<QtdBanheiros>4</QtdBanheiros>" <>
          "<QtdVagas>4</QtdVagas>" <>
          "<Fotos>" <>
          "<Foto>" <>
          "<NomeArquivo><![CDATA[living_room.png]]></NomeArquivo>" <>
          "<URLArquivo><![CDATA[#{@image_url}/living_room.png]]></URLArquivo>" <>
          "<Principal>0</Principal>" <>
          "<Ordem>1</Ordem>" <>
          "</Foto>" <>
          "<Foto>" <>
          "<NomeArquivo><![CDATA[suite_1.png]]></NomeArquivo>" <>
          "<URLArquivo><![CDATA[#{@image_url}/suite_1.png]]></URLArquivo>" <>
          "<Principal>0</Principal>" <>
          "<Ordem>2</Ordem>" <>
          "</Foto>" <>
          "</Fotos>" <>
          "<ToursVirtual360>" <>
          "<TourVirtual360>" <>
          "<URLArquivo><![CDATA[#{@tour_url}/?m=mY123]]></URLArquivo>" <>
          "</TourVirtual360>" <>
          "</ToursVirtual360>" <>
          "</Imovel>"

      generated_xml =
        listing
        |> Imovelweb.build_node(Imovelweb.merge_default_options(%{}))
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
        "<Imovel>" <>
          "<CodigoCentralVendas></CodigoCentralVendas>" <>
          "<CodigoImovel>7004578</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Padrão</SubTipoImovel>" <>
          "<TituloImovel>Apartamento a venda em São Paulo</TituloImovel>" <>
          "<Observacao><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></Observacao>" <>
          "<Modelo>SIMPLES</Modelo>" <>
          "<UF>SP</UF>" <>
          "<Cidade><![CDATA[São Paulo]]></Cidade>" <>
          "<Bairro><![CDATA[Ipiranga]]></Bairro>" <>
          "<Endereco><![CDATA[Rua do Ipiranga]]></Endereco>" <>
          "<Numero>20</Numero>" <>
          "<CEP>04732-192</CEP>" <>
          "<DivulgarEndereco>APROX</DivulgarEndereco>" <>
          "<Latitude>51.496401</Latitude>" <>
          "<Longitude>-0.179</Longitude>" <>
          "<VisualizarMapa>1</VisualizarMapa>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<AreaUtil>300</AreaUtil>" <>
          "<PrecoVenda>800</PrecoVenda>" <>
          "<PrecoCondominio/>" <>
          "<QtdDormitorios>4</QtdDormitorios>" <>
          "<QtdBanheiros>4</QtdBanheiros>" <>
          "<QtdVagas>4</QtdVagas>" <>
          "<Fotos/>" <>
          "<ToursVirtual360/>" <>
          "</Imovel>"

      generated_xml =
        listing
        |> Imovelweb.build_node(Imovelweb.merge_default_options(%{}))
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
        "<Imovel>" <>
          "<CodigoCentralVendas></CodigoCentralVendas>" <>
          "<CodigoImovel>7004578</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Padrão</SubTipoImovel>" <>
          "<TituloImovel>Apartamento a venda em São Paulo</TituloImovel>" <>
          "<Observacao><![CDATA[Sobrado, 4 dormitórios, 3 suites, 4 vagas de garagem, 2 salas , 1 lavabo, 1 banheiro, área de serviço]]></Observacao>" <>
          "<Modelo>SIMPLES</Modelo>" <>
          "<UF>SP</UF>" <>
          "<Cidade><![CDATA[São Paulo]]></Cidade>" <>
          "<Bairro><![CDATA[Ipiranga]]></Bairro>" <>
          "<Endereco><![CDATA[Rua do Ipiranga]]></Endereco>" <>
          "<Numero>20</Numero>" <>
          "<CEP>04732-192</CEP>" <>
          "<DivulgarEndereco>APROX</DivulgarEndereco>" <>
          "<Latitude>51.496401</Latitude>" <>
          "<Longitude>-0.179</Longitude>" <>
          "<VisualizarMapa>1</VisualizarMapa>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<AreaUtil>300</AreaUtil>" <>
          "<PrecoVenda>800</PrecoVenda>" <>
          "<PrecoCondominio/>" <>
          "<QtdDormitorios>0</QtdDormitorios>" <>
          "<QtdBanheiros>0</QtdBanheiros>" <>
          "<QtdVagas>0</QtdVagas>" <>
          "<Fotos/>" <>
          "<ToursVirtual360/>" <>
          "</Imovel>"

      generated_xml =
        listing
        |> Imovelweb.build_node(Imovelweb.merge_default_options(%{}))
        |> XmlBuilder.generate(format: :none)

      assert expected_xml == generated_xml
    end
  end

  describe "export_listing/1" do
    test "export listing with proper root node" do
      expected_xml =
        ~s|<?xml version="1.0" encoding="UTF-8"?>| <>
          ~s|<Carga xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">| <>
          "<Imoveis><Imovel><CodigoImovel>1</CodigoImovel></Imovel></Imoveis></Carga>"

      generated_xml = Imovelweb.export_listings_xml([%Listing{id: 1}], %{attributes: [:id]})

      assert expected_xml == generated_xml
    end
  end
end
