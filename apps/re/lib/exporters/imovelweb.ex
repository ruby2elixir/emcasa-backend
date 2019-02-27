defmodule Re.Exporters.Imovelweb do
  @moduledoc """
  Listing XML exporters for imovelweb
  """

  alias Re.Listing

  @exported_attributes ~w(internal_id id type subtype title description highlight state city neighborhood
    street street_number zipcode show_address lat lng show_map area_unity area price maintenance_fee rooms
    bathrooms garage_spots images tour)a
  @default_options %{attributes: @exported_attributes, highlight_ids: []}

  @imovelweb_id ""

  @image_url "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/"
  @tour_url "https://my.matterport.com"

  def export_listings_xml(listings, options \\ %{}) do
    options = merge_default_options(options)

    listings
    |> Enum.map(&build_node(&1, options))
    |> build_root()
    |> XmlBuilder.document()
    |> XmlBuilder.generate(format: :none)
  end

  def merge_default_options(options), do: Map.merge(@default_options, options)

  def build_node(listing, options) do
    {"Imovel", %{}, convert_attributes(listing, options)}
  end

  defp build_root(nodes) do
    {"Carga",
     %{
       :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
       :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema"
     }, [{"Imoveis", %{}, nodes}]}
  end

  def convert_attributes(listing, %{attributes: attributes} = options) do
    Enum.map(attributes, &convert_attribute(&1, listing, options))
  end

  defp convert_attribute(:internal_id, _, _), do: {"CodigoCentralVendas", %{}, @imovelweb_id}
  defp convert_attribute(:id, listing, _), do: {"CodigoImovel", %{}, listing.id}

  defp convert_attribute(:type, listing, _),
    do: {"TipoImovel", %{}, Map.get(listing_type_map(), listing.type, "Outro")}

  defp convert_attribute(:subtype, listing, _),
    do: {"SubTipoImovel", %{}, Map.get(listing_subtype_map(), listing.type, "Outro")}

  defp convert_attribute(:title, listing, _),
    do: {"TituloImovel", %{}, "#{listing.type} a venda em #{listing.address.city}"}

  defp convert_attribute(:description, listing, _),
    do: {"Observacao", %{}, {:cdata, listing.description}}

  defp convert_attribute(:highlight, listing, options) do
    {
      "Modelo",
      %{},
      cond do
        listing.id in Map.get(options, :highlight_ids, []) -> "DESTAQUE"
        true -> "SIMPLES"
      end
    }
  end

  defp convert_attribute(:state, listing, _), do: {"UF", %{}, listing.address.state}
  defp convert_attribute(:city, listing, _), do: {"Cidade", %{}, {:cdata, listing.address.city}}

  defp convert_attribute(:neighborhood, listing, _),
    do: {"Bairro", %{}, {:cdata, listing.address.neighborhood}}

  defp convert_attribute(:street, listing, _),
    do: {"Endereco", %{}, {:cdata, listing.address.street}}

  defp convert_attribute(:street_number, listing, _),
    do: {"Numero", %{}, listing.address.street_number}

  defp convert_attribute(:zipcode, listing, _), do: {"CEP", %{}, listing.address.postal_code}
  defp convert_attribute(:show_address, _, _), do: {"DivulgarEndereco", %{}, "APROX"}
  defp convert_attribute(:lat, listing, _), do: {"Latitude", %{}, listing.address.lat}
  defp convert_attribute(:lng, listing, _), do: {"Longitude", %{}, listing.address.lng}
  defp convert_attribute(:show_map, _, _), do: {"VisualizarMapa", %{}, 1}
  defp convert_attribute(:area_unity, _, _), do: {"UnidadeMetrica", %{}, "M2"}
  defp convert_attribute(:area, listing, _), do: {"AreaUtil", %{}, listing.area}
  defp convert_attribute(:price, listing, _), do: {"PrecoVenda", %{}, listing.price}

  defp convert_attribute(:maintenance_fee, listing, _),
    do: {"PrecoCondominio", %{}, listing.maintenance_fee}

  defp convert_attribute(:rooms, listing, _), do: {"QtdDormitorios", %{}, listing.rooms || 0}

  defp convert_attribute(:bathrooms, listing, _),
    do: {"QtdBanheiros", %{}, listing.bathrooms || 0}

  defp convert_attribute(:garage_spots, listing, _),
    do: {"QtdVagas", %{}, listing.garage_spots || 0}

  defp convert_attribute(:images, listing, _),
    do: {"Fotos", %{}, listing.images |> Enum.map(&build_image_node/1)}

  defp convert_attribute(:tour, listing, _),
    do: {"ToursVirtual360", %{}, build_tour_node(listing.matterport_code)}

  def listing_type_map(),
    do: Listing.listing_types() |> Enum.zip(~w(Apartamento Casa Apartamento)) |> Enum.into(%{})

  def listing_subtype_map(),
    do: Listing.listing_types() |> Enum.zip(~w(Padrão Padrão Cobertura)) |> Enum.into(%{})

  defp build_image_node(image) do
    {"Foto", %{},
     [
       {"NomeArquivo", %{}, {:cdata, image.filename}},
       {"URLArquivo", %{}, {:cdata, build_url(@image_url, [image.filename])}},
       {"Principal", %{}, 0},
       {"Ordem", %{}, image.position}
     ]}
  end

  defp build_tour_node(nil), do: nil

  defp build_tour_node(matterport_code) do
    [
      {"TourVirtual360", %{},
       [
         {"URLArquivo", %{}, {:cdata, build_url(@tour_url, ["/?m=#{matterport_code}"])}}
       ]}
    ]
  end

  def build_url(host, params) do
    params
    |> Enum.reduce(host, fn item, acc -> URI.merge(acc, item) end)
    |> URI.to_string()
  end
end
