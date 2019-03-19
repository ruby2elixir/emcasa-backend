defmodule Re.Exporters.Zap do
  @moduledoc """
  Listing XML exporters for zap
  """

  @normal 1
  @highlight 2
  @super_highlight 3

  @exported_attributes ~w(id type subtype category address state city neighborhood street_number complement
                          postal_code price maintenance_fee util_area area_unit rooms bathrooms garage_spots
                          property_tax description images highlight)a

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

  def convert_attributes(listing, %{attributes: attributes} = options),
    do: Enum.map(attributes, &convert_attribute(&1, listing, options))

  defp convert_attribute(:id, %{id: id}, _) do
    {"CodigoImovel", %{}, id}
  end

  defp convert_attribute(:type, listing, _) do
    {"TipoImovel", %{}, listing_type(listing)}
  end

  defp convert_attribute(:subtype, listing, _) do
    {"SubTipoImovel", %{}, listing_subtype(listing)}
  end

  defp convert_attribute(:category, listing, _) do
    {"CategoriaImovel", %{}, listing_category(listing)}
  end

  defp convert_attribute(:address, listing, _) do
    {"Endereco", %{}, listing.address.street}
  end

  defp convert_attribute(:state, listing, _) do
    {"UF", %{}, listing.address.state}
  end

  defp convert_attribute(:city, listing, _) do
    {"Cidade", %{}, listing.address.city}
  end

  defp convert_attribute(:neighborhood, listing, _) do
    {"Bairro", %{}, listing.address.neighborhood}
  end

  defp convert_attribute(:street_number, listing, _) do
    {"Numero", %{}, listing.address.street_number}
  end

  defp convert_attribute(:complement, listing, _) do
    {"Complemento", %{}, listing.complement}
  end

  defp convert_attribute(:postal_code, listing, _) do
    {"CEP", %{}, String.replace(listing.address.postal_code, "-", "")}
  end

  defp convert_attribute(:price, listing, _) do
    {"PrecoVenda", %{}, listing.price}
  end

  defp convert_attribute(:maintenance_fee, listing, _) do
    case listing.maintenance_fee do
      nil -> {"PrecoCondominio", %{}, ""}
      maintenance_fee -> {"PrecoCondominio", %{}, trunc(maintenance_fee)}
    end
  end

  defp convert_attribute(:util_area, listing, _) do
    {"AreaUtil", %{}, listing.area}
  end

  defp convert_attribute(:area_unit, _, _) do
    {"UnidadeMetrica", %{}, "M2"}
  end

  defp convert_attribute(:rooms, listing, _) do
    {"QtdDormitorios", %{}, listing.rooms}
  end

  defp convert_attribute(:bathrooms, listing, _) do
    {"QtdBanheiros", %{}, listing.bathrooms}
  end

  defp convert_attribute(:garage_spots, listing, _) do
    {"QtdVagas", %{}, listing.garage_spots}
  end

  defp convert_attribute(:property_tax, listing, _) do
    case listing.property_tax do
      nil -> {"ValorIPTU", %{}, ""}
      property_tax -> {"ValorIPTU", %{}, trunc(property_tax)}
    end
  end

  defp convert_attribute(:description, listing, _) do
    {"Observacao", %{}, listing.description}
  end

  defp convert_attribute(:images, %{images: []}, _), do: {"Fotos", %{}, nil}

  defp convert_attribute(:images, %{images: [main_image | rest]}, _) do
    main_image = Map.put(main_image, :main, true)
    {"Fotos", %{}, Enum.map([main_image | rest], &build_image/1)}
  end

  defp convert_attribute(:highlight, %{id: id}, %{
         highlight_ids: highlight_ids,
         super_highlight_ids: super_highlight_ids
       }) do
    cond do
      id in super_highlight_ids -> {"TipoOferta", %{}, @super_highlight}
      id in highlight_ids -> {"TipoOferta", %{}, @highlight}
      true -> {"TipoOferta", %{}, @normal}
    end
  end

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
