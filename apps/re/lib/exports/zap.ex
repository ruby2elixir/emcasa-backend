defmodule Re.Exporters.Zap do
  @exported_attributes ~w(id type subtype category address state city neighborhood street_number complement
                          postal_code price maintenance_fee util_area area_unit rooms bathrooms garage_spots
                          property_tax description featured images)a

  alias Re.{
    Images,
    Listings.Queries,
    Repo
  }

  @preload [
    :address,
    :zap_highlight,
    :zap_super_highlight,
    images: Images.Queries.listing_preload()
  ]

  def export_listings_xml(attributes \\ @exported_attributes) do
    Queries.active()
    |> Queries.preload_relations(@preload)
    |> Queries.order_by_id()
    |> Repo.all()
    |> Enum.map(&build_xml(&1, attributes))
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

  def build_xml(%Re.Listing{} = listing, attributes \\ @exported_attributes) do
    {"Imovel", %{}, convert_attributes(listing, attributes)}
  end

  def convert_attributes(listing, attributes),
    do: Enum.map(attributes, &convert_attribute(&1, listing))

  defp convert_attribute(:id, %{id: id}) do
    {"CodigoImovel", %{}, id}
  end

  defp convert_attribute(:type, listing) do
    {"TipoImovel", %{}, listing_type(listing)}
  end

  defp convert_attribute(:subtype, listing) do
    {"SubTipoImovel", %{}, listing_subtype(listing)}
  end

  defp convert_attribute(:category, listing) do
    {"CategoriaImovel", %{}, listing_category(listing)}
  end

  defp convert_attribute(:address, listing) do
    {"Endereco", %{}, listing.address.street}
  end

  defp convert_attribute(:state, listing) do
    {"UF", %{}, listing.address.state}
  end

  defp convert_attribute(:city, listing) do
    {"Cidade", %{}, listing.address.city}
  end

  defp convert_attribute(:neighborhood, listing) do
    {"Bairro", %{}, listing.address.neighborhood}
  end

  defp convert_attribute(:street_number, listing) do
    {"Numero", %{}, listing.address.street_number}
  end

  defp convert_attribute(:complement, listing) do
    {"Complemento", %{}, listing.complement}
  end

  defp convert_attribute(:postal_code, listing) do
    {"CEP", %{}, String.replace(listing.address.postal_code, "-", "")}
  end

  defp convert_attribute(:price, listing) do
    {"PrecoVenda", %{}, listing.price}
  end

  defp convert_attribute(:maintenance_fee, listing) do
    case listing.maintenance_fee do
      nil -> {"PrecoCondominio", %{}, ""}
      maintenance_fee -> {"PrecoCondominio", %{}, trunc(maintenance_fee)}
    end
  end

  defp convert_attribute(:util_area, listing) do
    {"AreaUtil", %{}, listing.area}
  end

  defp convert_attribute(:area_unit, _) do
    {"UnidadeMetrica", %{}, "M2"}
  end

  defp convert_attribute(:rooms, listing) do
    {"QtdDormitorios", %{}, listing.rooms}
  end

  defp convert_attribute(:bathrooms, listing) do
    {"QtdBanheiros", %{}, listing.bathrooms}
  end

  defp convert_attribute(:garage_spots, listing) do
    {"QtdVagas", %{}, listing.garage_spots}
  end

  defp convert_attribute(:property_tax, listing) do
    case listing.property_tax do
      nil -> {"ValorIPTU", %{}, ""}
      property_tax -> {"ValorIPTU", %{}, trunc(property_tax)}
    end
  end

  defp convert_attribute(:description, listing) do
    {"Observacao", %{}, listing.description}
  end

  defp convert_attribute(:images, %{images: []}), do: {"Fotos", %{}, nil}

  defp convert_attribute(:images, %{images: [main_image | rest]}) do
    main_image = Map.put(main_image, :main, true)
    {"Fotos", %{}, Enum.map([main_image | rest], &build_image/1)}
  end

  defp convert_attribute(:featured, %{zap_super_highlight: %Re.Listings.Highlights.ZapSuper{}}) do
    {"TipoOferta", %{}, 3}
  end

  defp convert_attribute(:featured, %{zap_highlight: %Re.Listings.Highlights.Zap{}}) do
    {"TipoOferta", %{}, 2}
  end

  defp convert_attribute(:featured, _) do
    {"TipoOferta", %{}, 1}
  end

  defp build_image(%{filename: filename} = image) do
    {"Foto", %{},
     [
       {"URLArquivo", %{},
        "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename},
       {"NomeArquivo", %{}, filename},
       {"Alterada", %{}, 0}
     ]
     |> main_picture(image)}
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
