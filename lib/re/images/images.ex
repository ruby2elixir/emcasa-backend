defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Image,
    Images.Queries,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Images.Policy

  def all(listing_id) do
    Queries.by_listing(listing_id)
    |> Queries.active()
    |> Queries.order_by_position()
    |> Repo.all()
  end

  def get(id) do
    Queries.active()
    |> Repo.get(id)
    |> case do
      nil -> {:error, :not_found}
      image -> {:ok, image}
    end
  end

  def insert(image_params, listing) do
    %Image{}
    |> Image.create_changeset(image_params)
    |> Changeset.change(listing: listing)
    |> Changeset.change(is_active: true)
    |> Changeset.change(position: calculate_position(listing))
    |> Repo.insert()
  end

  defp calculate_position(%{images: []}), do: 1
  defp calculate_position(%{images: [top_image | _]}), do: top_image.position - 1

  def update_per_listing(listing, images_params) do
    Enum.each(images_params, &update_image(listing, &1))
  end

  defp update_image(listing, %{"id" => id} = params) do
    image = Repo.get(Image, id)

    if image.listing_id == listing.id do
      image
      |> Image.update_changeset(params)
      |> Repo.update()
    end
  end

  def deactivate(image) do
    image
    |> Image.deactivate_changeset(%{is_active: false})
    |> Repo.update()
  end
end
