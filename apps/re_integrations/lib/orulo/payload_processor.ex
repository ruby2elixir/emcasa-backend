defmodule ReIntegrations.Orulo.PayloadProcessor do
  @moduledoc """
  Module to delegate payloads to processors.
  """

  alias __MODULE__.Buildings, as: BuildingProcessor
  alias __MODULE__.Images, as: ImageProcessor
  alias __MODULE__.Tags, as: TagsProcessor

  defdelegate insert_development_from_building_payload(multi, building_uuid),
    to: BuildingProcessor

  defdelegate insert_images_from_image_payload(multi, payload_uuid), to: ImageProcessor
  defdelegate process_orulo_tags(multi, payload_uuid), to: TagsProcessor
end
