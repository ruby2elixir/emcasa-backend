defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """

  import Ecto.Query

  alias Re.{
    Image,
    Repo
  }

  def all(%{"listing_id" => listing_id}) do
    q = from i in Image,
      where: i.listing_id == ^listing_id,
      order_by: [asc: i.position]

    {:ok, Repo.all(q)}
  end
  def all(_), do: {:error, :bad_request}

  def get_per_listing(listing_id, image_id) do
    case Repo.get_by(Image, id: image_id, listing_id: listing_id) do
      nil -> {:error, :not_found}
      image -> {:ok, image}
    end
  end

  def insert(image_params, listing_id) do
    %Image{}
    |> Image.changeset(Map.put(image_params, "listing_id", listing_id))
    |> Repo.insert()
  end

  def update_per_listing(_listing, images_param) do
    Enum.each(images_param, &update_image/1)
  end

  defp update_image(%{"id" => id} = params) do
    image = Repo.get(Image, id)

    image
    |> Image.changeset(params)
    |> Repo.update()
  end

  def delete(image), do: Repo.delete(image)

end
