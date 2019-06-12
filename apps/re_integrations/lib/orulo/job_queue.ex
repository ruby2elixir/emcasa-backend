defmodule ReIntegrations.Orulo.JobQueue do
  @moduledoc """
  Module for processing jobs related with orulo entitiens payloads.
  """
  use EctoJob.JobQueue, table_name: "orulo_jobs", schema_prefix: "re_integrations"

  require Ecto.Query
  require Logger

  alias ReIntegrations.{
    Orulo,
    Orulo.Client,
    Orulo.PayloadProcessor
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "import_development_from_orulo", "external_id" => id}) do
    with {:ok, %{body: body}} <- Client.get_building(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, _} <-
           Orulo.multi_building_payload_insert(multi, %{external_id: id, payload: payload}) do
    else
      {:error, error} -> Logger.error(error)
      error -> Logger.error(error)
    end
  end

  def perform(%Multi{} = multi, %{"type" => "fetch_images_from_orulo", "external_id" => id}) do
    with {:ok, %{body: body}} <- Client.get_images(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, _} <-
           Orulo.multi_images_payload_insert(multi, %{external_id: id, payload: payload}) do
    else
      {:error, error} -> Logger.error(error)
      error -> Logger.error(error)
    end
  end

  def perform(%Multi{} = multi, %{"type" => "fetch_typology", "building_id" => id}) do
    with {:ok, %{body: body}} <- Client.get_typologies(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, _} <-
           Orulo.insert_typologies_payload(multi, %{
             building_id: Integer.to_string(id),
             payload: payload
           }) do
    else
      {:error, error} -> Logger.error(error)
      error -> Logger.error(error)
    end
  end

  def perform(%Multi{} = multi, %{"type" => "parse_building_into_development", "uuid" => uuid}) do
    PayloadProcessor.insert_development_from_building_payload(multi, uuid)
  end

  def perform(%Multi{} = multi, %{
        "type" => "parse_images_payloads_into_images",
        "uuid" => uuid
      }) do
    PayloadProcessor.insert_images_from_image_payload(multi, uuid)
  end

  def perform(%Multi{} = multi, %{
        "type" => "process_orulo_tags",
        "uuid" => uuid
      }) do
    PayloadProcessor.process_orulo_tags(multi, uuid)
  end
end
