defmodule ReIntegrations.Orulo.PayloadsProcessor do
  @moduledoc """
  Module to process payloads into internal representations.
  """

  alias ReIntegrations.Orulo.PayloadProcessors.Buildings, as: BuildingProcessor
  alias ReIntegrations.Orulo.PayloadProcessors.Images, as: ImageProcessor
  alias ReIntegrations.Orulo.PayloadProcessors.Tags, as: TagsProcessor

  def insert_development_from_building_payload(multi, building_uuid) do
    BuildingProcessor.insert_development_from_building_payload(multi, building_uuid)
  end

  def insert_images_from_image_payload(multi, payload_uuid) do
    ImageProcessor.insert_images_from_image_payload(multi, payload_uuid)
  end

  def process_orulo_tags(multi, payload_uuid) do
    TagsProcessor.process_orulo_tags(multi, payload_uuid)
  end
end
