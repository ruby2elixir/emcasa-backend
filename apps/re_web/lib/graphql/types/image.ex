defmodule ReWeb.Types.Image do
  @moduledoc """
  GraphQL types for images
  """
  use Absinthe.Schema.Notation

  alias ReWeb.Resolvers

  object :image do
    field :id, :id
    field :filename, :string
    field :position, :integer
    field :is_active, :boolean
    field :description, :string
  end

  input_object :image_insert_input do
    field :listing_id, non_null(:id)
    field :filename, non_null(:string)
    field :is_active, :boolean
    field :description, :string
  end

  input_object :image_update_input do
    field :id, non_null(:id)
    field :position, :integer
    field :description, :string
  end

  input_object :image_deactivate_input do
    field :image_ids, non_null(list_of(non_null(:id)))
  end

  input_object :image_activate_input do
    field :image_ids, non_null(list_of(non_null(:id)))
  end

  object :image_output do
    field :images, list_of(:image)
    field :parent_listing, :listing
  end

  object :image_mutations do
    @desc "Inser image"
    field :insert_image, type: :image do
      arg :input, non_null(:image_insert_input)

      resolve &Resolvers.Images.insert_image/2
    end

    @desc "Update images"
    field :update_images, type: :image_output do
      arg :input, non_null(list_of(non_null(:image_update_input)))

      resolve &Resolvers.Images.update_images/2
    end

    @desc "Deactivate images"
    field :images_deactivate, type: :image_output do
      arg :input, non_null(:image_deactivate_input)

      resolve &Resolvers.Images.deactivate_images/2
    end

    @desc "Deactivate images"
    field :images_activate, type: :image_output do
      arg :input, non_null(:image_activate_input)

      resolve &Resolvers.Images.activate_images/2
    end
  end

  object :image_subscriptions do
    @desc "Subscribe to image deactivation"
    field :images_deactivated, :image_output do
      arg :listing_id, non_null(:id)

      config(&Resolvers.Images.images_deactivated_config/2)

      trigger :images_deactivate, topic: &Resolvers.Images.images_deactivate_trigger/1
    end

    @desc "Subscribe to image activation"
    field :images_activated, :image_output do
      arg :listing_id, non_null(:id)

      config(&Resolvers.Images.images_activated_config/2)

      trigger :images_activate, topic: &Resolvers.Images.images_activate_trigger/1
    end

    @desc "Subscribe to image update"
    field :images_updated, :image_output do
      arg :listing_id, non_null(:id)

      config(&Resolvers.Images.images_updated_config/2)

      trigger :update_images, topic: &Resolvers.Images.update_images_trigger/1
    end
  end
end
