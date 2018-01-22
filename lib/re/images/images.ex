defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """
  @behaviour Bodyguard.Policy

  import Ecto.Query

  alias Re.{
    Image,
    Repo
  }

  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Images.Policy

  def all(listing_id) do
    q =
      from(
        i in Image,
        where: i.listing_id == ^listing_id,
        where: i.is_active == true,
        order_by: [asc: i.position]
      )

    {:ok, Repo.all(q)}
  end

  def get_per_listing(listing_id, image_id) do
    case Repo.get_by(Image, id: image_id, listing_id: listing_id, is_active: true) do
      nil -> {:error, :not_found}
      image -> {:ok, image}
    end
  end

  def insert(image_params, listing_id) do
    %Image{}
    |> Image.create_changeset(image_params)
    |> Changeset.change(is_active: true)
    |> Changeset.change(listing_id: listing_id)
    |> Changeset.change(position: calculate_position(listing_id))
    |> Repo.insert()
  end

  defp calculate_position(listing_id) do
    case all(listing_id) do
      {:ok, []} -> 1
      {:ok, [top_image | _]} -> top_image.position - 1
    end
  end

  def update_per_listing(listing, images_params) do
    Enum.each(images_params, &update_image(listing, &1))
  end

  defp update_image(listing, %{"id" => id} = params) do
    image = Repo.get(Image, id)

    if image.listing_id == listing.id do
      image
      |> Image.position_changeset(params)
      |> Repo.update()
    end
  end

  def delete(image) do
    image
    |> Image.delete_changeset()
    |> Changeset.change(is_active: false)
    |> Repo.update()
  end
end
