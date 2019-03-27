defmodule Re.Exporters.FacebookAds.Product do
  @moduledoc """
  Listing XML exporter for Facebook Dynamic Product Ads
  https://developers.facebook.com/docs/marketing-api/dynamic-product-ads/product-catalog
  """

  @exported_attributes ~w(id url title sell_type condition brand description price
  listing_type address rooms bathrooms area image)a
  @default_options %{attributes: @exported_attributes}

  @frontend_url Application.get_env(:re_integrations, :frontend_url)
  @image_url "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385"

  def export_listings_xml(listings, options \\ %{}) do
    options = merge_default_options(options)

    listings
    |> Enum.filter(&has_image?/1)
    |> Enum.map(&build_node(&1, options))
    |> build_root()
    |> XmlBuilder.document()
    |> XmlBuilder.generate(format: :none)
  end

  defp has_image?(%{images: []}), do: false
  defp has_image?(_), do: true

  def merge_default_options(options) do
    Map.merge(@default_options, options)
  end

  def build_node(listing, options) do
    {"entry", %{}, convert_attributes(listing, options)}
  end

  defp build_root(nodes) do
    {"feed", %{xmlns: "http://www.w3.org/2005/Atom"}, nodes}
  end

  def convert_attributes(listing, %{attributes: attributes}) do
    Enum.map(attributes, &convert_attribute_with_cdata(&1, listing))
  end

  defp convert_attribute_with_cdata(attr, listing) do
    {tag, attrs, value} = convert_attribute(attr, listing)
    {tag, attrs, escape_cdata(value)}
  end

  defp convert_attribute(:id, %{id: id}) do
    {"id", %{}, id}
  end

  defp convert_attribute(:url, %{id: id}) do
    {"link", %{}, build_url(@frontend_url, "/imoveis/", to_string(id))}
  end

  defp convert_attribute(:title, %{type: type, address: %{city: city}}) do
    {"title", %{}, "#{type} a venda em #{city}"}
  end

  defp convert_attribute(:sell_type, _) do
    {"availability", %{}, "in stock"}
  end

  defp convert_attribute(:condition, _) do
    {"condition", %{}, "new"}
  end

  defp convert_attribute(:brand, _) do
    {"brand", %{}, "EmCasa"}
  end

  defp convert_attribute(:description, %{description: description}) do
    {"description", %{}, description}
  end

  defp convert_attribute(:price, %{price: price}) do
    {"price", %{}, "#{price} BRL"}
  end

  defp convert_attribute(:image, %{images: []}) do
    {"image_link", %{}, nil}
  end

  defp convert_attribute(:image, %{images: images}) do
    first_image = Enum.at(images, 0)

    {
      "image_link",
      %{},
      "#{@image_url}/#{first_image.filename}"
    }
  end

  defp convert_attribute(:listing_type, %{type: type}) do
    {"custom_label_0", %{}, type}
  end

  defp convert_attribute(:address, %{address: address}) do
    {
      "custom_label_1",
      %{},
      "#{address.street}, #{address.neighborhood}"
    }
  end

  defp convert_attribute(:rooms, %{rooms: rooms}) do
    {"custom_label_2", %{}, rooms || 0}
  end

  defp convert_attribute(:bathrooms, %{bathrooms: bathrooms}) do
    {"custom_label_3", %{}, bathrooms || 0}
  end

  defp convert_attribute(:area, %{area: area}) do
    {"custom_label_4", %{}, area}
  end

  defp escape_cdata(nil) do
    nil
  end

  defp escape_cdata(value) when is_binary(value) do
    {:cdata, value}
  end

  defp escape_cdata(value) do
    escape_cdata(to_string(value))
  end

  defp build_url(host, path, param) do
    host
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end
end
