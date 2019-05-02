defmodule ReWeb.Resolvers.Images do
  @moduledoc """
  Resolver module for images
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Development,
    Developments,
    Images,
    Listing,
    Listings
  }

  def per_listing(listing, params, %{context: %{loader: loader, current_user: current_user}}) do
    params = Map.put(params, :has_admin_rights, has_admin_rights?(current_user, listing))

    loader
    |> Dataloader.load(
      Re.Images,
      {:images, params},
      listing
    )
    |> on_load(fn loader ->
      images =
        loader
        |> Dataloader.get(
          Re.Images,
          {:images, params},
          listing
        )
        |> limit(params)

      {:ok, images}
    end)
  end

  def per_development(development, params, %{
        context: %{loader: loader, current_user: current_user}
      }) do
    params = Map.put(params, :has_admin_rights, has_admin_rights?(current_user, development))

    loader
    |> Dataloader.load(
      Re.Images,
      {:images, params},
      development
    )
    |> on_load(fn loader ->
      images =
        loader
        |> Dataloader.get(
          Re.Images,
          {:images, params},
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
         {:ok, parent} <- Images.get_parent(images_and_inputs),
         :ok <- Bodyguard.permit(Images, :update_images, current_user, parent),
         {:ok, images} <- Images.update_images(images_and_inputs),
         do: {:ok, %{images: images, parent_listing: parent, parent: parent}}
  end

  def deactivate_images(%{input: %{image_ids: image_ids}}, %{
        context: %{current_user: current_user}
      }) do
    with images <- Images.list_by_ids(image_ids),
         {:ok, parent} <- Images.get_parent(images),
         :ok <- Bodyguard.permit(Images, :deactivate_images, current_user, parent),
         {:ok, images} <- Images.deactivate_images(images),
         do: {:ok, %{images: images, parent_listing: parent, parent: parent}}
  end

  def images_deactivated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_deactivated")
  end

  def images_updated_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_updated")
  end

  def image_inserted_config(args, %{context: %{current_user: current_user}}) do
    config_subscription(args, current_user, "images_inserted")
  end

  def images_deactivate_trigger(%{parent_listing: %{id: id}}), do: "images_deactivated:#{id}"

  def images_deactivate_trigger(%{parent: %Re.Development{uuid: uuid}}),
    do: "development_updated:#{uuid}"

  def update_images_trigger(%{parent_listing: %{id: id}}), do: "images_updated:#{id}"

  def update_images_trigger(%{parent: %Re.Development{uuid: uuid}}),
    do: "development_updated:#{uuid}"

  def insert_image_trigger(%{parent_listing: %{id: id}}), do: "images_inserted:#{id}"

  def insert_image_trigger(%{parent: %Re.Development{uuid: uuid}}),
    do: "development_updated:#{uuid}"

  defp has_admin_rights?(user, %Listing{} = listing) do
    case Bodyguard.permit(Listings, :has_admin_rights, user, listing) do
      :ok -> true
      _ -> false
    end
  end

  defp has_admin_rights?(user, %Development{} = development) do
    case Bodyguard.permit(Developments, :has_admin_rights, user, development) do
      :ok -> true
      _ -> false
    end
  end

  defp config_subscription(%{listing_id: id}, %{role: "admin"}, topic),
    do: {:ok, topic: "#{topic}:#{id}"}

  defp config_subscription(_args, %{}, _topic), do: {:error, :unauthorized}
  defp config_subscription(_args, _, _topic), do: {:error, :unauthenticated}

  defp limit(images, %{limit: limit}), do: Enum.take(images, limit)
  defp limit(images, _), do: images
end
