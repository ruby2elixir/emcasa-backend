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

  object :image_mutations do
    @desc "Inser image"
    field :insert_image, type: :image do
      arg :input, non_null(:image_insert_input)

      resolve &Resolvers.Images.insert_image/2
    end

    @desc "Update images"
    field :update_images, type: list_of(:image) do
      arg :input, non_null(list_of(non_null(:image_update_input)))

      resolve &Resolvers.Images.update_images/2
    end

    @desc "Deactivate images"
    field :images_deactivate, type: list_of(:image) do
      arg :input, non_null(:image_deactivate_input)

      resolve &Resolvers.Images.deactivate_images/2
    end

    @desc "Deactivate images"
    field :images_activate, type: list_of(:image) do
      arg :input, non_null(:image_activate_input)

      resolve &Resolvers.Images.activate_images/2
    end
  end

  object :image_subscriptions do
    @desc "Subscribe to image deactivation"
    field :images_deactivated, list_of(:image) do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{role: "admin"} -> {:ok, topic: "images_deactivated"}
          %{} -> {:error, :unauthorized}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :images_deactivate,
        topic: fn _ -> "images_deactivated" end
    end

    @desc "Subscribe to image activation"
    field :images_activated, list_of(:image) do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{role: "admin"} -> {:ok, topic: "images_activated"}
          %{} -> {:error, :unauthorized}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :images_activate,
        topic: fn _ -> "images_activated" end
    end

    @desc "Subscribe to image update"
    field :images_updated, list_of(:image) do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          %{role: "admin"} -> {:ok, topic: "images_updated"}
          %{} -> {:error, :unauthorized}
          _ -> {:error, :unauthenticated}
        end
      end)

      trigger :update_images,
        topic: fn _ -> "images_updated" end
    end
  end
end