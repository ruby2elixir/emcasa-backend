defmodule ReWeb.Exporters.Zap.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.{
    Exporters.Zap,
    Listings.Exporter,
    Listings.Highlights
  }

  def init(args), do: args

  def call(
        %Plug.Conn{path_info: [state_slug, city_slug], query_params: query_params} = conn,
        _args
      ) do
    filters = %{cities_slug: [city_slug], states_slug: [state_slug]}

    options = get_highlights(filters, query_params)

    xml_listings =
      filters
      |> Exporter.exportable(query_params)
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

  defp get_highlights(%{cities_slug: [city_slug]} = filters, query_params) do
    highlights_size = Highlights.get_zap_highlights_size(city_slug)
    super_highlights_size = Highlights.get_zap_super_highlights_size(city_slug)

    highlights_params =
      query_params
      |> Map.put(:filters, filters)
      |> Map.put(:page_size, highlights_size)
      |> Map.put(:offset, super_highlights_size)

    super_highlights_params =
      query_params
      |> Map.put(:filters, filters)
      |> Map.put(:page_size, super_highlights_size)

    highlight_ids = Highlights.get_highlight_listing_ids(highlights_params)

    super_highlight_ids = Highlights.get_highlight_listing_ids(super_highlights_params)

    %{super_highlight_ids: super_highlight_ids, highlight_ids: highlight_ids}
  end
end
