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
    Orulo.PayloadProcessor,
    Orulo.TypologyPayload
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "import_development_from_orulo", "external_id" => id}) do
    with {:ok, %{body: body}} <- Client.get_building(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, _} <-
           Orulo.multi_building_payload_insert(multi, %{external_id: id, payload: payload}) do
    else
      error -> Logger.error("Error on building request: #{Kernel.inspect(error)}")
    end
  end

  def perform(%Multi{} = multi, %{"type" => "fetch_images_from_orulo", "external_id" => id}) do
    with {:ok, %{body: body}} <- Client.get_images(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, _} <-
           Orulo.multi_images_payload_insert(multi, %{external_id: id, payload: payload}) do
    else
      error -> Logger.error("Error on image request: #{Kernel.inspect(error)}")
    end
  end

  def perform(%Multi{} = multi, %{"type" => "fetch_typologies", "building_id" => id}) do
    with {:ok, %{body: body}} <- Client.get_typologies(id),
         {:ok, payload} <- Jason.decode(body),
         {:ok, new_typology_payload} <-
           Orulo.insert_typologies_payload(multi, %{
             building_id: Integer.to_string(id),
             payload: payload
           }) do
      {:ok, new_typology_payload}
    else
      error -> Logger.error("Error on typology request:  #{Kernel.inspect(error)}")
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

  def perform(%Multi{} = multi, %{
        "type" => "process_units",
        "uuid" => uuid
      }) do
    PayloadProcessor.process_typologies(multi, uuid)
  end

  def perform(%Multi{} = multi, %{
        "type" => "fetch_units",
        "uuid" => uuid
      }) do
    %{payload: %{"typologies" => typologies}, building_id: building_id} =
      ReIntegrations.Repo.get(TypologyPayload, uuid)

    typology_ids =
      typologies
      |> Enum.map(fn %{"id" => id} -> id end)

    responses = Orulo.get_units(building_id, typology_ids)
    Orulo.bulk_insert_unit_payloads(multi, building_id, responses)
  end
end
