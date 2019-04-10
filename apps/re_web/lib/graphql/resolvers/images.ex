defmodule ReWeb.Resolvers.Images do
  @moduledoc """
  Resolver module for images
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Developments,
    Images,
    Listings
  }

  def per_listing(listing, params, %{context: %{loader: loader, current_user: current_user}}) do
    is_admin? = admin_rights?(listing, current_user)

    loader
    |> Dataloader.load(
      Re.Images,
      {:images, Map.put(params, :has_admin_rights, is_admin?)},
      listing
    )
    |> on_load(fn loader ->
      images =
        loader
        |> Dataloader.get(
          Re.Images,
          {:images, Map.put(params, :has_admin_rights, is_admin?)},
          listing
        )
        |> limit(params)

      {:ok, images}
    end)
  end

  def per_development(development, params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    is_admin? = admin_rights?(nil, current_user)

    loader
    |> Dataloader.load(
      Re.Images,
      {:images, Map.put(params, :has_admin_rights, is_admin?)},
      development
    )
    |> on_load(fn loader ->
      images =
        loader
        |> Dataloader.get(
          Re.Images,
          {:images, Map.put(params, :has_admin_rights, is_admin?)},
          development
        )

      {:ok, images}
    end)
  end

  def insert_image(%{input: %{parent_type: :development, parent_uuid: parent_uuid} = params}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- Bodyguard.permit(Images, :create_development_images, current_user, nil),
         {:ok, development} <- Developments.get_preloaded(parent_uuid, [:images]),
         {:ok, image} <- Images.insert(params, development) do
      {:ok, %{parent: development, image: image}}
    end
  end

  def insert_image(%{input: %{listing_id: listing_id} = params}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, listing} <- Listings.get_preloaded(listing_id),
         :ok <- Bodyguard.permit(Images, :create_images, current_user, listing),
         {:ok, image} <- Images.insert(params, listing),
         do: {:ok, %{parent_listing: listing, image: image}}
  end

  def update_images(%{input: inputs}, %{context: %{current_user: current_user}}) do
    with {:ok, images_and_inputs} <- Images.get_list(inputs),
         {:ok, parent} <-
           extract_image_list(images_and_inputs) |> Images.Parents.get_image_parent(),
         :ok <- Bodyguard.permit(Images, :update_images, current_user, parent),
         {:ok, images} <- Images.update_images(images_and_inputs),
         do: {:ok, %{images: images, parent_listing: parent, parent: parent}}
  end

  defp extract_image_list(images_and_inputs),
    do: Enum.map(images_and_inputs, fn {_, image, _} -> image end)

  def deactivate_images(%{input: %{image_ids: image_ids}}, %{
        context: %{current_user: current_user}
      }) do
    with images <- Images.list_by_ids(image_ids),
         {:ok, listing} <- Images.fetch_listing(images),
         :ok <- Bodyguard.permit(Images, :deactivate_images, current_user, listing),
         {:ok, images} <- Images.deactivate_images(images),
         do: {:ok, %{images: images, parent_listing: listing}}
  end

  def activate_images(%{input: %{image_ids: image_ids}}, %{context: %{current_user: current_user}}) do
    with images <- Images.list_by_ids(image_ids),
         {:ok, listing} <- Images.fetch_listing(images),
         :ok <- Bodyguard.permit(Images, :activate_images, current_user, listing),
         {:ok, images} <- Images.activate_images(images),
         do: {:ok, %{images: images, parent_listing: listing}}
  end

  def images_deactivated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_deactivated")
  end

  def images_activated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_activated")
  end

  def images_updated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_updated")
  end

  def image_inserted_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_inserted")
  end

  def images_deactivate_trigger(%{parent_listing: %{id: id}}), do: "images_deactivated:#{id}"

  def images_activate_trigger(%{parent_listing: %{id: id}}), do: "images_activated:#{id}"

  def update_images_trigger(%{parent_listing: %{id: id}}), do: "images_updated:#{id}"

  def update_images_trigger(%{parent: %Re.Development{uuid: uuid}}),
    do: "development_updated:#{uuid}"

  def insert_image_trigger(%{parent_listing: %{id: id}}), do: "images_inserted:#{id}"

  def insert_image_trigger(%{parent: %Re.Development{uuid: uuid}}),
    do: "development_updated:#{uuid}"

  defp config_subscription(%{listing_id: id}, %{role: "admin"}, topic),
    do: {:ok, topic: "#{topic}:#{id}"}

  defp config_subscription(_args, %{}, _topic), do: {:error, :unauthorized}
  defp config_subscription(_args, _, _topic), do: {:error, :unauthenticated}

  defp admin_rights?(%{user_id: user_id}, %{id: user_id}), do: true
  defp admin_rights?(_, %{role: "admin"}), do: true
  defp admin_rights?(_, _), do: false

  defp limit(images, %{limit: limit}), do: Enum.take(images, limit)
  defp limit(images, _), do: images
end
