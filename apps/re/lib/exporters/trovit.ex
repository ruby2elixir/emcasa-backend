defmodule Re.Exporters.Trovit do
  @moduledoc """
  Listing XML exporter for trovit.
  """

  @exported_attributes ~w(id url title sell_type description price listing_type area rooms
    bathrooms garage_spots state city neighborhood postal_code latitude longitude owner agency
    pictures)a

  @frontend_url Application.get_env(:re_integrations, :frontend_url)

  def export_listing_xml(listings, options \\ %{}) do
    listings
    |> Enum.map(&build_xml(&1, options))
    |> root_xml()
    |> XmlBuilder.document()
    |> XmlBuilder.generate(format: :none)
  end

  def build_xml(listing, options) do
    {"ad", %{}, convert_attributes(listing, options)}
  end

  defp root_xml(ads) do
    {"trovit", %{}, ads}
  end

  def convert_attributes(listing, _) do
    Enum.map(@exported_attributes, &convert_attribute_with_cdata(&1, listing))
  end

  defp convert_attribute_with_cdata(:pictures = attr, listing) do
    convert_attribute(attr, listing)
  end

  defp convert_attribute_with_cdata(attr, listing) do
    {tag, attrs, value} = convert_attribute(attr, listing)
    {tag, attrs, escape_cdata(value)}
  end

  defp convert_attribute(:id, %{id: id}) do
    {"id", %{}, id}
  end

  defp convert_attribute(:url, %{id: id}) do
    {"url", %{}, build_url("/imoveis/", to_string(id))}
  end

  defp convert_attribute(:title, %{type: type, address: %{city: city}}) do
    {"title", %{}, "#{type} a venda em #{city}"}
  end

  defp convert_attribute(:sell_type, _) do
    {"type", %{}, "For Sale"}
  end

  defp convert_attribute(:description, %{description: description}) do
    {"content", %{}, description}
  end

  defp convert_attribute(:price, %{price: price}) do
    {"price", %{}, price}
  end

  defp convert_attribute(:listing_type, %{type: type}) do
    {"property_type", %{}, type}
  end

  defp convert_attribute(:area, %{area: area}) do
    {"floor_area", %{}, area}
  end

  defp convert_attribute(:rooms, %{rooms: rooms}) do
    {"rooms", %{}, rooms}
  end

  defp convert_attribute(:bathrooms, %{bathrooms: bathrooms}) do
    {"bathrooms", %{}, bathrooms}
  end

  defp convert_attribute(:garage_spots, %{garage_spots: garage_spots}) do
    {"parking", %{}, garage_spots}
  end

  defp convert_attribute(:state, %{address: %{state: state}}) do
    {"region", %{}, expand_state(state)}
  end

  defp convert_attribute(:city, %{address: %{city: city}}) do
    {"city", %{}, city}
  end

  defp convert_attribute(:neighborhood, %{address: %{neighborhood: neighborhood}}) do
    {"city_area", %{}, neighborhood}
  end

  defp convert_attribute(:address, %{address: %{street: street, street_number: street_number}}) do
    {"address", %{}, "#{street}, #{street_number}"}
  end

  defp convert_attribute(:postal_code, %{address: %{postal_code: postal_code}}) do
    {"postcode", %{}, postal_code}
  end

  defp convert_attribute(:latitude, %{address: %{lat: lat}}) do
    {"latitude", %{}, lat}
  end

  defp convert_attribute(:longitude, %{address: %{lng: lng}}) do
    {"longitude", %{}, lng}
  end

  defp convert_attribute(:pictures, %{images: []}) do
    {"pictures", %{}, nil}
  end

  defp convert_attribute(:pictures, %{images: images}) do
    {"pictures", %{}, Enum.map(images, &build_image/1)}
  end

  defp convert_attribute(:owner, _) do
    # TODO (jpd): discover what an owner means
    {"by_owner", %{}, "-"}
  end

  defp convert_attribute(:agency, _) do
    # TODO (jpd): discover what an agency meas
    {"agency", %{}, "-"}
  end

  defp build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end

  defp expand_state("RJ"), do: "Rio de Janeiro"
  defp expand_state("SP"), do: "São Paulo"
  defp expand_state(state), do: state

  defp build_image(%{filename: filename, description: description}) do
    {
      "picture",
      %{},
      [
        {"picture_url", %{},
         escape_cdata(
           "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/#{filename}"
         )},
        {"picture_title", %{}, escape_cdata(description)}
      ]
    }
  end

  defp escape_cdata(value) when is_binary(value) do
    {:cdata, value}
  end

  defp escape_cdata(value) do
    escape_cdata(to_string(value))
  end
end
