defmodule Re.Exporters.Vivareal do

  @exported_attributes ~w(id title transaction_type featured inserted_at updated_at detail_url
                          images details location contact_info)a

  @frontend_url Application.get_env(:re, :frontend_url)

  alias Re.{
    Images,
    Listings,
    Listings.Queries,
    Repo
  }

  import Ecto.Query

  def export_listings_xml(attributes \\ @exported_attributes) do
    Queries.active()
    |> Queries.preload_relations([:address, images: Images.Queries.listing_preload()])
    |> Queries.order_by_id()
    |> Repo.all()
    |> Enum.map(&build_xml(&1, attributes))
    |> wrap_tags()
    |> XmlBuilder.generate(format: :none)
  end

  defp wrap_tags(listings) do
    {"ListingDataFeed", %{
      :xmlns => "http://www.vivareal.com/schemas/1.0/VRSync",
      :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      :"xsi:schemaLocation" => "http://www.vivareal.com/schemas/1.0/VRSync  http://xml.vivareal.com/vrsync.xsd"
      }, [
      build_header(),
      {"Listings", %{}, listings}
    ]}
  end

  defp build_header do
    {"Header", %{}, [
      {"Provider", %{}, "EmCasa"},
      {"Email", %{}, "rodrigo.nonose@emcasa.com"},
      {"ContactName", %{}, "Rodrigo Nonose"}
    ]}
  end

  def build_xml(%Re.Listing{} = listing, attributes \\ @exported_attributes) do
    {"Listing", %{}, convert_attributes(listing, attributes)}
  end

  def convert_attributes(listing, attributes), do: Enum.map(attributes, &convert_attribute(&1, listing))

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

  defp convert_attribute(:inserted_at, %{inserted_at: inserted_at}) do
    {"ListDate", %{}, Timex.format!(inserted_at, "%Y-%m-%dT%H:%M:%S", :strftime)}
  end

  defp convert_attribute(:updated_at, %{updated_at: updated_at}) do
    {"LastUpdateDate", %{}, Timex.format!(updated_at, "%Y-%m-%dT%H:%M:%S", :strftime)}
  end

  defp convert_attribute(:detail_url, %{id: id}) do
    {"DetailViewUrl", %{}, build_url("/imoveis/", to_string(id))}
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
      {"PropertyAdministrationFee", %{currency: "BRL"}, trunc(listing.maintenance_fee)},
      {"YearlyTax", %{currency: "BRL"}, trunc(listing.property_tax)},
      {"Bedrooms", %{}, listing.rooms},
      {"Bathrooms", %{}, listing.bathrooms},
    ]}
  end

  defp convert_attribute(:location, %{address: address}) do
    {"Location", %{displayAddress: "Neighborhood"}, [
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

  defp convert_attribute(:contact_info, _) do
    {"ContactInfo", %{}, [
      {"Name", %{}, "EmCasa"},
      {"Email", %{}, "contato@emcasa.com"},
      {"Website", %{}, "https://www.emcasa.com"},
      {"Logo", %{}, "https://s3.amazonaws.com/emcasa-ui/logo/logo.png"},
      {"OfficeName", %{}, "EmCasa"},
      {"Telephone", %{}, "(21) 3195-6541"}
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

  defp build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end
end
