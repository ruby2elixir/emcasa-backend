defmodule ReIntegrations.Orulo.PayloadsProcessor do
  @moduledoc """
  Module to process payloads into internal representations.
  """

  alias Ecto.Multi

  alias Re.{
    Developments,
    DevelopmentTag,
    Tags
  }

  alias ReIntegrations.{
    Orulo.BuildingPayload,
    Orulo.TagMapper,
    Repo
  }

  alias ReIntegrations.Orulo.PayloadProcessors.Buildings, as: BuildingProcessor
  alias ReIntegrations.Orulo.PayloadProcessors.Images, as: ImageProcessor

  def insert_development_from_building_payload(multi, building_uuid) do
    BuildingProcessor.insert_development_from_building_payload(multi, building_uuid)
  end

  def insert_images_from_image_payload(multi, payload_uuid) do
    ImageProcessor.insert_images_from_image_payload(multi, payload_uuid)
  end

  def process_orulo_tags(multi, uuid) do
    %{payload: %{"id" => external_id}} = building = Repo.get(BuildingPayload, uuid)
    {:ok, development} = Developments.get_by_orulo_id(external_id)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    developments_tags =
      building
      |> TagMapper.map_tags()
      |> Tags.list_by_slugs()
      |> Enum.map(fn tag ->
        %{
          development_uuid: development.uuid,
          tag_uuid: tag.uuid,
          inserted_at: now,
          updated_at: now
        }
      end)

    multi
    |> Multi.insert_all(:insert_tags, DevelopmentTag, developments_tags)
    |> Re.Repo.transaction()
  end
end
