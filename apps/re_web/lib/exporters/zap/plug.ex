defmodule ReWeb.Exporters.Zap.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.{
    Exporters.Zap,
    Filtering,
    Listings.Exporter,
    Listings.Highlights,
    Listings.Queries
  }

  def init(args), do: args

  def call(
        %Plug.Conn{path_info: [state_slug, city_slug], query_params: query_params} = conn,
        _args
      ) do
    filters = %{cities_slug: [city_slug], states_slug: [state_slug]}
    options = mount_options(city_slug, state_slug)

    xml_listings =
      Exporter.exportable(filters, query_params)
      |> Zap.export_listings_xml(options)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml_listings)
  end

  def call(conn, _args) do
    error_response =
      {"error", "Expect state and city on path"}
      |> XmlBuilder.document()
      |> XmlBuilder.generate(format: :none)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(404, error_response)
  end

  defp mount_options(city_slug, state_slug) do
    filters = %{cities_slug: [city_slug], states_slug: [state_slug]}

    query =
      Queries.active()
      |> Filtering.apply(filters)
      |> Queries.preload_relations([:address])
      |> Queries.order_by_id()

    super_highlights_count = super_highlights_count(city_slug)
    highlights_count = highlights_count(city_slug)

    super_highlights =
      Highlights.get_highlight_listing_ids(query, %{page_size: super_highlights_count})

    highlights =
      Highlights.get_highlight_listing_ids(query, %{
        page_size: highlights_count,
        offset: super_highlights_count
      })

    %{super_highlights: super_highlights, highlights: highlights}
  end

  defp super_highlights_count(city_slug) do
    counter_map = %{"sao-paulo" => 3, "rio-de-janeiro" => 5}

    Map.get(counter_map, city_slug, 0)
  end

  defp highlights_count(city_slug) do
    counter_map = %{"sao-paulo" => 100, "rio-de-janeiro" => 300}

    Map.get(counter_map, city_slug, 0)
  end
end
