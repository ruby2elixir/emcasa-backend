defmodule Re.Exporters.Zap do
  @moduledoc """
  Listing XML exporters for zap
  """

  @normal 1
  @highlight 2
  @super_highlight 3

  @exported_attributes ~w(id type subtype category address state city neighborhood street_number complement
                          price maintenance_fee util_area area_unit rooms bathrooms garage_spots
                          property_tax description images highlight tags)a

  @default_options %{attributes: @exported_attributes, highlight_ids: [], super_highlight_ids: []}

  def export_listings_xml(listings, options \\ %{}) do
    listings
    |> Enum.map(&build_xml(&1, options))
    |> wrap_tags()
    |> XmlBuilder.document()
    |> XmlBuilder.generate(format: :none)
  end

  defp wrap_tags(listings) do
    {"Carga",
     %{
       :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
       :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema"
     },
     [
       {"Imoveis", %{}, listings}
     ]}
  end

  def build_xml(%Re.Listing{} = listing, options \\ %{}) do
    options = merge_defaults(options)

    {"Imovel", %{}, convert_attributes(listing, options)}
  end

  def convert_attributes(listing, %{attributes: attributes} = options) do
    attributes
    |> Enum.reverse()
    |> Enum.reduce([], &convert_attribute(&1, listing, options, &2))
  end

  defp convert_attribute(:id, %{id: id}, _, acc) do
    [{"CodigoImovel", %{}, id} | acc]
  end

  defp convert_attribute(:type, listing, _, acc) do
    [{"TipoImovel", %{}, listing_type(listing)} | acc]
  end

  defp convert_attribute(:subtype, listing, _, acc) do
    [{"SubTipoImovel", %{}, listing_subtype(listing)}, acc]
  end

  defp convert_attribute(:category, listing, _, acc) do
    [{"CategoriaImovel", %{}, listing_category(listing)} | acc]
  end

  defp convert_attribute(:address, listing, _, acc) do
    [{"Endereco", %{}, listing.address.street} | acc]
  end

  defp convert_attribute(:state, listing, _, acc) do
    [{"UF", %{}, listing.address.state} | acc]
  end

  defp convert_attribute(:city, listing, _, acc) do
    [{"Cidade", %{}, listing.address.city} | acc]
  end

  defp convert_attribute(:neighborhood, listing, _, acc) do
    [{"Bairro", %{}, listing.address.neighborhood} | acc]
  end

  defp convert_attribute(:street_number, listing, _, acc) do
    [{"Numero", %{}, listing.address.street_number} | acc]
  end

  defp convert_attribute(:complement, listing, _, acc) do
    [{"Complemento", %{}, listing.complement} | acc]
  end

  defp convert_attribute(:price, listing, _, acc) do
    [{"PrecoVenda", %{}, listing.price} | acc]
  end

  defp convert_attribute(:maintenance_fee, listing, _, acc) do
    case listing.maintenance_fee do
      nil -> [{"PrecoCondominio", %{}, ""} | acc]
      maintenance_fee -> [{"PrecoCondominio", %{}, trunc(maintenance_fee)} | acc]
    end
  end

  defp convert_attribute(:util_area, listing, _, acc) do
    [{"AreaUtil", %{}, listing.area} | acc]
  end

  defp convert_attribute(:area_unit, _, _, acc) do
    [{"UnidadeMetrica", %{}, "M2"} | acc]
  end

  defp convert_attribute(:rooms, listing, _, acc) do
    [{"QtdDormitorios", %{}, listing.rooms} | acc]
  end

  defp convert_attribute(:bathrooms, listing, _, acc) do
    [{"QtdBanheiros", %{}, listing.bathrooms} | acc]
  end

  defp convert_attribute(:garage_spots, listing, _, acc) do
    [{"QtdVagas", %{}, listing.garage_spots} | acc]
  end

  defp convert_attribute(:property_tax, listing, _, acc) do
    case listing.property_tax do
      nil -> [{"ValorIPTU", %{}, ""} | acc]
      property_tax -> [{"ValorIPTU", %{}, trunc(property_tax)} | acc]
    end
  end

  defp convert_attribute(:description, listing, _, acc) do
    [{"Observacao", %{}, listing.description} | acc]
  end

  defp convert_attribute(:images, %{images: []}, _, acc), do: [{"Fotos", %{}, nil} | acc]

  defp convert_attribute(:images, %{images: [main_image | rest]}, _, acc) do
    main_image = Map.put(main_image, :main, true)
    [{"Fotos", %{}, Enum.map([main_image | rest], &build_image/1)} | acc]
  end

  defp convert_attribute(
         :highlight,
         %{id: id},
         %{
           highlight_ids: highlight_ids,
           super_highlight_ids: super_highlight_ids
         },
         acc
       ) do
    cond do
      id in super_highlight_ids -> [{"TipoOferta", %{}, @super_highlight} | acc]
      id in highlight_ids -> [{"TipoOferta", %{}, @highlight} | acc]
      true -> [{"TipoOferta", %{}, @normal} | acc]
    end
  end

  defp convert_attribute(:tags, %{tags: tags}, _, acc) do
    tags_xml = Enum.reduce(tags, [], &convert_tag/2)

    tags_xml ++ acc
  end

  defp convert_tag(%{name_slug: "academia"}, acc), do: [{"Academia", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "churrasqueira"}, acc), do: [{"Churrasqueira", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "espaco-verde"}, acc), do: [{"Jardim", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "espaco-gourmet"}, acc), do: [{"EspacoGourmet", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "piscina"}, acc), do: [{"Piscina", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "playground"}, acc), do: [{"Playground", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "quadra"}, acc), do: [{"QuadraPoliEsportiva", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "salao-de-festas"}, acc), do: [{"SalaoFestas", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "salao-de-jogos"}, acc), do: [{"SalaoJogos", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "sauna"}, acc), do: [{"Sauna", %{}, nil} | acc]

  defp convert_tag(%{name_slug: "armarios-embutidos"}, acc),
    do: [{"ArmarioEmbutido", %{}, nil} | acc]

  defp convert_tag(%{name_slug: "dependencia-empregados"}, acc),
    do: [{"QuartoWCEmpregada", %{}, nil} | acc]

  defp convert_tag(%{name_slug: "banheiro-empregados"}, acc),
    do: [{"WCEmpregada", %{}, nil} | acc]

  defp convert_tag(%{name_slug: "fogao-embutido"}, acc), do: [{"Fogao", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "lavabo"}, acc), do: [{"Lavabo", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "terraco"}, acc), do: [{"Terraco", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "varanda"}, acc), do: [{"Varanda", %{}, nil} | acc]
  defp convert_tag(%{name_slug: "varanda-gourmet"}, acc), do: [{"VarandaGourmet", %{}, nil} | acc]

  defp convert_tag(%{name_slug: "portaria-24-horas"}, acc),
    do: [{"Acesso24Horas", %{}, nil} | acc]

  defp convert_tag(_tag, acc), do: acc

  defp merge_defaults(map) do
    Map.merge(@default_options, map)
  end

  defp build_image(%{filename: filename} = image) do
    {"Foto", %{},
     main_picture(
       [
         {"URLArquivo", %{},
          "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename},
         {"NomeArquivo", %{}, filename},
         {"Alterada", %{}, 0}
       ],
       image
     )}
  end

  defp main_picture(tags, %{main: true}), do: [{"Principal", %{}, 1} | tags]
  defp main_picture(tags, _), do: tags

  defp listing_type(%{type: "Casa"}), do: "Casa"
  defp listing_type(_), do: "Apartamento"

  defp listing_subtype(%{type: "Casa"}), do: "Casa Padrão"
  defp listing_subtype(_), do: "Apartamento Padrão"

  defp listing_category(%{type: "Casa"}), do: "Térrea"
  defp listing_category(%{type: "Cobertura"}), do: "Cobertura"
  defp listing_category(_), do: "Padrão"
end
