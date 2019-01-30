defmodule Re.Exporters.ZapTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.{
    Exporters.Zap,
    Listing,
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
              postal_code: "11111-111"
            ),
          complement: "basement",
          images: images,
          description: "descr",
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          garage_spots: 1,
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      expected_xml =
        "<Imovel>" <>
          "<CodigoImovel>#{id}</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Apartamento Padrão</SubTipoImovel>" <>
          "<CategoriaImovel>Padrão</CategoriaImovel>" <>
          "<Endereco>Avenida Atlântica</Endereco>" <>
          "<UF>RJ</UF>" <>
          "<Cidade>Rio de Janeiro</Cidade>" <>
          "<Bairro>Copacabana</Bairro>" <>
          "<Numero>55</Numero>" <>
          "<Complemento>basement</Complemento>" <>
          "<CEP>11111111</CEP>" <>
          "<PrecoVenda>1000000</PrecoVenda>" <>
          "<PrecoCondominio>1000</PrecoCondominio>" <>
          "<AreaUtil>50</AreaUtil>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<QtdDormitorios>2</QtdDormitorios>" <>
          "<QtdBanheiros>2</QtdBanheiros>" <>
          "<QtdVagas>1</QtdVagas>" <>
          "<ValorIPTU>1000</ValorIPTU>" <>
          "<Observacao>descr</Observacao>" <>
          images_tags() <> "<TipoOferta>1</TipoOferta>" <> "</Imovel>"

      assert expected_xml == listing |> Zap.build_xml() |> XmlBuilder.generate(format: :none)
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
              postal_code: "11111-111"
            ),
          complement: "basement",
          images: images,
          description: nil,
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          garage_spots: 1,
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      expected_xml =
        "<Imovel>" <>
          "<CodigoImovel>#{id}</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Apartamento Padrão</SubTipoImovel>" <>
          "<CategoriaImovel>Padrão</CategoriaImovel>" <>
          "<Endereco>Avenida Atlântica</Endereco>" <>
          "<UF>RJ</UF>" <>
          "<Cidade>Rio de Janeiro</Cidade>" <>
          "<Bairro>Copacabana</Bairro>" <>
          "<Numero>55</Numero>" <>
          "<Complemento>basement</Complemento>" <>
          "<CEP>11111111</CEP>" <>
          "<PrecoVenda>1000000</PrecoVenda>" <>
          "<PrecoCondominio>1000</PrecoCondominio>" <>
          "<AreaUtil>50</AreaUtil>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<QtdDormitorios>2</QtdDormitorios>" <>
          "<QtdBanheiros>2</QtdBanheiros>" <>
          "<QtdVagas>1</QtdVagas>" <>
          "<ValorIPTU>1000</ValorIPTU>" <>
          "<Observacao/>" <> images_tags() <> "<TipoOferta>1</TipoOferta>" <> "</Imovel>"

      assert expected_xml == listing |> Zap.build_xml() |> XmlBuilder.generate(format: :none)
    end

    test "export XML from listing with no images" do
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
              postal_code: "11111-111"
            ),
          complement: "basement",
          images: [],
          description: nil,
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          garage_spots: 1,
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      expected_xml =
        "<Imovel>" <>
          "<CodigoImovel>#{id}</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Apartamento Padrão</SubTipoImovel>" <>
          "<CategoriaImovel>Padrão</CategoriaImovel>" <>
          "<Endereco>Avenida Atlântica</Endereco>" <>
          "<UF>RJ</UF>" <>
          "<Cidade>Rio de Janeiro</Cidade>" <>
          "<Bairro>Copacabana</Bairro>" <>
          "<Numero>55</Numero>" <>
          "<Complemento>basement</Complemento>" <>
          "<CEP>11111111</CEP>" <>
          "<PrecoVenda>1000000</PrecoVenda>" <>
          "<PrecoCondominio>1000</PrecoCondominio>" <>
          "<AreaUtil>50</AreaUtil>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<QtdDormitorios>2</QtdDormitorios>" <>
          "<QtdBanheiros>2</QtdBanheiros>" <>
          "<QtdVagas>1</QtdVagas>" <>
          "<ValorIPTU>1000</ValorIPTU>" <>
          "<Observacao/>" <> "<Fotos/>" <> "<TipoOferta>1</TipoOferta>" <> "</Imovel>"

      assert expected_xml == listing |> Zap.build_xml() |> XmlBuilder.generate(format: :none)
    end

    test "export XML with highlight" do
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
              postal_code: "11111-111"
            ),
          complement: "basement",
          images: images,
          description: "descr",
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          garage_spots: 1,
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      options = %{highlight_ids: [id]}

      expected_xml =
        "<Imovel>" <>
          "<CodigoImovel>#{id}</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Apartamento Padrão</SubTipoImovel>" <>
          "<CategoriaImovel>Padrão</CategoriaImovel>" <>
          "<Endereco>Avenida Atlântica</Endereco>" <>
          "<UF>RJ</UF>" <>
          "<Cidade>Rio de Janeiro</Cidade>" <>
          "<Bairro>Copacabana</Bairro>" <>
          "<Numero>55</Numero>" <>
          "<Complemento>basement</Complemento>" <>
          "<CEP>11111111</CEP>" <>
          "<PrecoVenda>1000000</PrecoVenda>" <>
          "<PrecoCondominio>1000</PrecoCondominio>" <>
          "<AreaUtil>50</AreaUtil>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<QtdDormitorios>2</QtdDormitorios>" <>
          "<QtdBanheiros>2</QtdBanheiros>" <>
          "<QtdVagas>1</QtdVagas>" <>
          "<ValorIPTU>1000</ValorIPTU>" <>
          "<Observacao>descr</Observacao>" <>
          images_tags() <> "<TipoOferta>2</TipoOferta>" <> "</Imovel>"

      assert expected_xml ==
               listing |> Zap.build_xml(options) |> XmlBuilder.generate(format: :none)
    end

    test "export XML with super highlight" do
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
              postal_code: "11111-111"
            ),
          complement: "basement",
          images: images,
          description: "descr",
          area: 50,
          price: 1_000_000,
          rooms: 2,
          bathrooms: 2,
          garage_spots: 1,
          maintenance_fee: 1000.00,
          property_tax: 1000.00
        )

      options = %{super_highlight_ids: [id]}

      expected_xml =
        "<Imovel>" <>
          "<CodigoImovel>#{id}</CodigoImovel>" <>
          "<TipoImovel>Apartamento</TipoImovel>" <>
          "<SubTipoImovel>Apartamento Padrão</SubTipoImovel>" <>
          "<CategoriaImovel>Padrão</CategoriaImovel>" <>
          "<Endereco>Avenida Atlântica</Endereco>" <>
          "<UF>RJ</UF>" <>
          "<Cidade>Rio de Janeiro</Cidade>" <>
          "<Bairro>Copacabana</Bairro>" <>
          "<Numero>55</Numero>" <>
          "<Complemento>basement</Complemento>" <>
          "<CEP>11111111</CEP>" <>
          "<PrecoVenda>1000000</PrecoVenda>" <>
          "<PrecoCondominio>1000</PrecoCondominio>" <>
          "<AreaUtil>50</AreaUtil>" <>
          "<UnidadeMetrica>M2</UnidadeMetrica>" <>
          "<QtdDormitorios>2</QtdDormitorios>" <>
          "<QtdBanheiros>2</QtdBanheiros>" <>
          "<QtdVagas>1</QtdVagas>" <>
          "<ValorIPTU>1000</ValorIPTU>" <>
          "<Observacao>descr</Observacao>" <>
          images_tags() <> "<TipoOferta>3</TipoOferta>" <> "</Imovel>"

      assert expected_xml ==
               listing |> Zap.build_xml(options) |> XmlBuilder.generate(format: :none)
    end
  end

  describe "export_listings_xml/1" do
    test "should export listings wrapped" do
      listing = insert(:listing)

      listings = Listing |> Repo.all()

      assert ~s|<?xml version="1.0" encoding="UTF-8"?><Carga xmlns:xsd="http://www.w3.org/2001/XMLSchema" | <>
               ~s|xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">| <>
               ~s|<Imoveis><Imovel><CodigoImovel>#{listing.id}</CodigoImovel></Imovel></Imoveis></Carga>| ==
               Zap.export_listings_xml(listings, %{attributes: ~w(id)a})
    end
  end

  defp images_tags do
    "<Fotos>" <>
      "<Foto>" <>
      "<Principal>1</Principal>" <>
      "<URLArquivo>https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test1.jpg</URLArquivo>" <>
      "<NomeArquivo>test1.jpg</NomeArquivo>" <>
      "<Alterada>0</Alterada>" <>
      "</Foto>" <>
      "<Foto>" <>
      "<URLArquivo>https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test2.jpg</URLArquivo>" <>
      "<NomeArquivo>test2.jpg</NomeArquivo>" <>
      "<Alterada>0</Alterada>" <>
      "</Foto>" <>
      "<Foto>" <>
      "<URLArquivo>https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/test3.jpg</URLArquivo>" <>
      "<NomeArquivo>test3.jpg</NomeArquivo>" <>
      "<Alterada>0</Alterada>" <> "</Foto>" <> "</Fotos>"
  end
end
