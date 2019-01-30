defmodule ReWeb.Exporters.Zap.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.{
    Exporters.Zap,
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
    highlights_sizes = get_highlight_sizes(city_slug)

    options =
      Queries.highlights(filters)
      |> get_highlights(highlights_sizes)

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

  defp get_highlight_sizes(city_slug) do
    super_highlights_size = Highlights.get_zap_super_highlights_size(city_slug)
    highlights_size = Highlights.get_zap_highlights_size(city_slug)

    %{highlights_size: highlights_size, super_highlights_size: super_highlights_size}
  end

  defp get_highlights(query, %{
         highlights_size: highlights_size,
         super_highlights_size: super_highlights_size
       }) do
    highlight_ids =
      Highlights.get_highlight_listing_ids(query, %{
        page_size: highlights_size,
        offset: super_highlights_size
      })

    super_highlight_ids =
      Highlights.get_highlight_listing_ids(query, %{page_size: super_highlights_size})

    %{super_highlight_ids: super_highlight_ids, highlight_ids: highlight_ids}
  end
end
