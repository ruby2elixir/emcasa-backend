defmodule Re.Exporters.Vivareal do
  @moduledoc """
  Listing XML exporters for vivareal
  """
  @exported_attributes ~w(id title transaction_type highlight inserted_at updated_at detail_url
                          images details location contact_info)a

  @listing_types ~w(Apartment Home Penthouse)

  @frontend_url Application.get_env(:re_integrations, :frontend_url)

  @default_options %{attributes: @exported_attributes, highlight_ids: []}

  def export_listings_xml(listings, options \\ %{}) do
    listings
    |> Enum.filter(&has_image?/1)
    |> Enum.map(&build_xml(&1, options))
    |> wrap_tags()
    |> XmlBuilder.document()
    |> XmlBuilder.generate(format: :none)
  end

  defp has_image?(%{images: []}), do: false
  defp has_image?(_), do: true

  defp wrap_tags(listings) do
    {"ListingDataFeed",
     %{
       :xmlns => "http://www.vivareal.com/schemas/1.0/VRSync",
       :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
       :"xsi:schemaLocation" =>
         "http://www.vivareal.com/schemas/1.0/VRSync  http://xml.vivareal.com/vrsync.xsd"
     },
     [
       build_header(),
       {"Listings", %{}, listings}
     ]}
  end

  defp build_header do
    {"Header", %{},
     [
       {"Provider", %{}, "EmCasa"},
       {"Email", %{}, "rodrigo.nonose@emcasa.com"},
       {"ContactName", %{}, "Rodrigo Nonose"}
     ]}
  end

  def build_xml(%Re.Listing{} = listing, options \\ %{}) do
    options = merge_defaults(options)

    {"Listing", %{}, convert_attributes(listing, options)}
  end

  def convert_attributes(listing, %{attributes: attributes} = options),
    do: Enum.map(attributes, &convert_attribute(&1, listing, options))

  defp convert_attribute(:id, %{id: id}, _) do
    {"ListingID", %{}, id}
  end

  defp convert_attribute(:title, %{type: type, address: %{city: city}}, _) do
    {"Title", %{}, "#{type} a venda em #{city}"}
  end

  defp convert_attribute(:transaction_type, _, _) do
    {"TransactionType", %{}, "For Sale"}
  end

  defp convert_attribute(:highlight, %{id: id}, %{
         highlight_ids: highlight_ids
       }) do
    cond do
      id in highlight_ids -> {"Featured", %{}, true}
      true -> {"Featured", %{}, false}
    end
  end

  defp convert_attribute(:inserted_at, %{inserted_at: inserted_at}, _) do
    {"ListDate", %{}, Timex.format!(inserted_at, "%Y-%m-%dT%H:%M:%S", :strftime)}
  end

  defp convert_attribute(:updated_at, %{updated_at: updated_at}, _) do
    {"LastUpdateDate", %{}, Timex.format!(updated_at, "%Y-%m-%dT%H:%M:%S", :strftime)}
  end

  defp convert_attribute(:detail_url, %{id: id}, _) do
    {"DetailViewUrl", %{}, build_url("/imoveis/", to_string(id))}
  end

  defp convert_attribute(:images, %{images: images}, _) do
    {"Media", %{}, Enum.map(images, &build_image/1)}
  end

  @details_attributes ~w(type description price area maintenance_fee property_tax rooms bathrooms suites garage_spots)a

  defp convert_attribute(:details, listing, _) do
    {"Details", %{},
     @details_attributes
     |> Enum.reduce([], &build_details(&1, &2, listing))
     |> Enum.reverse()}
  end

  defp convert_attribute(:location, %{address: address}, _) do
    {"Location", %{displayAddress: "Neighborhood"},
     [
       {"Country", %{abbreviation: "BR"}, "Brasil"},
       {"State", %{abbreviation: address.state}, expand_state(address.state)},
       {"City", %{}, address.city},
       {"Neighborhood", %{}, address.neighborhood},
       {"Address", %{}, address.street},
       {"StreetNumber", %{}, address.street_number},
       {"PostalCode", %{}, address.postal_code},
       {"Latitude", %{}, address.lat},
       {"Longitude", %{}, address.lng}
     ]}
  end

  defp convert_attribute(:contact_info, _, _) do
    {"ContactInfo", %{},
     [
       {"Name", %{}, "EmCasa"},
       {"Email", %{}, "contato@emcasa.com"},
       {"Website", %{}, "https://www.emcasa.com"},
       {"Logo", %{}, "https://s3.amazonaws.com/emcasa-ui/logo/logo.png"},
       {"OfficeName", %{}, "EmCasa"},
       {"Telephone", %{}, "(21) 3195-6541"}
     ]}
  end

  defp build_details(:type, acc, listing) do
    [{"PropertyType", %{}, "Residential / #{translate_type(listing.type)}"} | acc]
  end

  defp build_details(:description, acc, listing) do
    [{"Description", %{}, add_description_timestamp(listing)} | acc]
  end

  defp build_details(:price, acc, listing) do
    [{"ListPrice", %{}, listing.price} | acc]
  end

  defp build_details(:area, acc, listing) do
    [{"LivingArea", %{unit: "square metres"}, listing.area} | acc]
  end

  defp build_details(:maintenance_fee, acc, listing) do
    case listing.maintenance_fee do
      nil ->
        acc

      maintenance_fee ->
        [{"PropertyAdministrationFee", %{currency: "BRL"}, trunc(maintenance_fee)} | acc]
    end
  end

  defp build_details(:property_tax, acc, listing) do
    case listing.property_tax do
      nil -> acc
      property_tax -> [{"YearlyTax", %{currency: "BRL"}, trunc(property_tax)} | acc]
    end
  end

  defp build_details(:rooms, acc, listing) do
    [{"Bedrooms", %{}, listing.rooms || 0} | acc]
  end

  defp build_details(:bathrooms, acc, listing) do
    [{"Bathrooms", %{}, listing.bathrooms || 0} | acc]
  end

  defp build_details(:suites, acc, listing) do
    [{"Suites", %{}, listing.suites || 0} | acc]
  end

  defp build_details(:garage_spots, acc, listing) do
    [{"Garage", %{type: "Parking Space"}, listing.garage_spots || 0} | acc]
  end

  defp build_image(%{filename: filename, description: description}) do
    {"Item", %{caption: description, medium: "image"},
     "https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename}
  end

  defp translate_type(type), do: Map.get(listing_type_map(), type, "Other")

  defp expand_state("RJ"), do: "Rio de Janeiro"
  defp expand_state("SP"), do: "São Paulo"
  defp expand_state(state), do: state

  defp build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end

  def listing_type_map(),
    do: Re.Listing.listing_types() |> Enum.zip(@listing_types) |> Enum.into(%{})

  defp merge_defaults(options) do
    Map.merge(@default_options, options)
  end

  defp add_description_timestamp(%{description: nil, updated_at: updated_at}),
    do: {:cdata, "Atualizado em: #{to_string(Timex.to_date(updated_at))}"}

  defp add_description_timestamp(%{description: description, updated_at: updated_at}) do
    {:cdata, description <> "\n Atualizado em: #{to_string(Timex.to_date(updated_at))}"}
  end
end
