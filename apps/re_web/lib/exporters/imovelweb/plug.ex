defmodule ReWeb.Exporters.Imovelweb.Plug do
  @moduledoc """
  Plug to handle pipedrive webhooks
  """
  import Plug.Conn

  alias Re.{
    Exporters.Imovelweb,
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
      Exporter.exportable(filters, query_params)
      |> Imovelweb.export_listings_xml(options)

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
    highlights_size = Highlights.get_imovelweb_highlights_size(city_slug)
    super_highlights_size = Highlights.get_imovelweb_super_highlights_size(city_slug)

    %{
      super_highlight_ids:
        get_highlights_ids(city_slug, filters, query_params, super_highlights_size),
      highlight_ids:
        get_highlights_ids(
          city_slug,
          filters,
          query_params,
          highlights_size,
          super_highlights_size
        )
    }
  end

  def get_highlights_ids(city_slug, filters, query_params, page_size, offset \\ 0) do
    params =
      query_params
      |> Map.put(:filters, filters)
      |> Map.put(:page_size, page_size)
      |> Map.put(:offset, offset)

    Highlights.get_highlight_listing_ids(params)
  end
end
