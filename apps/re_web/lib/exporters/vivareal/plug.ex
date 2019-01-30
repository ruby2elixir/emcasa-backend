defmodule ReWeb.Exporters.Vivareal.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.{
    Exporters.Vivareal,
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
    highlights_size = Highlights.get_vivareal_highlights_size(city_slug)

    options =
      Queries.highlights(filters)
      |> get_highlights(highlights_size)

    xml_listings =
      Exporter.exportable(filters, query_params)
      |> Vivareal.export_listings_xml(options)

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

  defp get_highlights(query, highlights_size) do
    highlight_ids =
      Highlights.get_highlight_listing_ids(query, %{
        page_size: highlights_size
      })

    %{highlight_ids: highlight_ids}
  end
end
