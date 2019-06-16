defmodule ReIntegrations.Orulo.Client do
  @moduledoc """
  Module to wripe orulo API logic
  """

  @http_client Application.get_env(:re_integrations, :http, HTTPoison)
  @base_url Application.get_env(:re_integrations, :orulo_url, "http://localhost:3000")
  @api_token Application.get_env(:re_integrations, :orulo_api_token, "")

  @api_headers [{"Authorization", "Bearer #{@api_token}"}]

  def get_building(id) when is_integer(id) do
    @base_url
    |> build_uri("buildings/#{id}")
    |> @http_client.get(@api_headers)
  end

  def get_units(building_id, typology_id) do
    @base_url
    |> build_uri("buildings/#{building_id}/typologies/#{typology_id}/units")
    |> @http_client.get(@api_headers)
  end

  def get_images(id) do
    dimensions_param = "dimensions[]=1024x1024"

    @base_url
    |> build_uri("buildings/#{id}/images?#{dimensions_param}")
    |> @http_client.get(@api_headers)
  end

  def get_typologies(id) do
    @base_url
    |> build_uri("buildings/#{id}/typologies")
    |> @http_client.get(@api_headers)
  end

  def build_uri(url, type) do
    url
    |> URI.parse()
    |> URI.merge(type)
  end
end
