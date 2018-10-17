defmodule Re.Exporters.Vivareal do

  @exported_attributes ~w(id title transaction_type featured images details location contact_info)a

  def export_xml(%Re.Listing{} = listing) do
    attributes = convert_attributes(listing)
    {"Listing", %{}, attributes}
    |> XmlBuilder.generate(format: :none)
  end

  def convert_attributes(listing), do: Enum.map(@exported_attributes, &convert_attribute(&1, listing))

  defp convert_attribute(:id, %{id: id}) do
    {"ListingId", %{}, id}
  end

  defp convert_attribute(:title, %{type: type, address: %{city: city}}) do
    {"Title", %{}, "#{type} a venda em #{city}"}
  end

  defp convert_attribute(:transaction_type, _) do
    {"TransactionType", %{}, "For Sale"}
  end

  defp convert_attribute(:featured, %{featured_vivareal: featured_vivareal}) do
    {"Featured", %{}, featured_vivareal}
  end

  defp convert_attribute(:featured, _) do
    {"Featured", %{}, false}
  end

  defp convert_attribute(:images, %{images: images}) do
    {"Media", %{}, Enum.map(images, &build_image/1)}
  end

  defp convert_attribute(:details, listing) do
    {"Details", %{}, [
      {"PropertyType", %{}, "Residential / #{translate_type(listing.type)}"},
      {"Description", %{}, "<![CDATA[" <> listing.description <> "]]>"},
      {"ListPrice", %{}, listing.price},
      {"LivingArea", %{unit: "square metres"}, listing.area},
      {"Bedrooms", %{}, listing.rooms},
      {"Bathrooms", %{}, listing.bathrooms},
    ]}
  end

  defp convert_attribute(:location, %{address: address}) do
    {"Location", %{displayAddress: "Neighborhood"}, [
      {"Country", %{abbreviation: "BR"}, "Brasil"},
      {"State", %{abbreviation: address.state}, expand_state(address.state)},
      {"City", %{}, address.city},
      {"Neighborhood", %{}, address.neighborhood}
    ]}
  end

  defp convert_attribute(:contact_info, _) do
    {"ContactInfo", %{}, [
      {"Name", %{}, "EmCasa"},
      {"Email", %{}, "contato@emcasa.com"}
    ]}
  end

  defp build_image(%{filename: filename, description: description}) do
    {"Item", %{caption: description, medium: "image"},"https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename}
  end

  defp translate_type("Apartamento"), do: "Apartment"

  defp translate_type(_), do: "Other"

  defp expand_state("RJ"), do: "Rio de Janeiro"
  defp expand_state("SP"), do: "São Paulo"
  defp expand_state(state), do: state
end
