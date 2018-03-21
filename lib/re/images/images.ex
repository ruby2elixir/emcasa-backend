defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Image,
    Repo
  }

  alias Re.Images.Queries, as: IQ
  alias Ecto.Changeset

  defdelegate authorize(action, user, params), to: Re.Images.Policy

  def all(listing_id) do
    IQ.by_listing(listing_id)
    |> IQ.active()
    |> IQ.order_by_position()
    |> Repo.all()
  end

  def get(id) do
    IQ.active()
    |> Repo.get(id)
    |> case do
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
      [] -> 1
      [top_image | _] -> top_image.position - 1
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
