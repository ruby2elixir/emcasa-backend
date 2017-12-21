defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """

  import Ecto.Query

  alias Re.{
    Image,
    Repo,
    Listing
  }

  def all(%{"listing_id" => listing_id}) do
    q = from i in Image,
      where: i.listing_id == ^listing_id,
      order_by: [asc: i.position]

    {:ok, Repo.all(q)}
  end
  def all(_), do: {:error, :bad_request}

  def update_per_listing(_listing, images_param) do
    Enum.each(images_param, &update_image/1)
  end

  defp update_image(%{"id" => id} = params) do
    image = Repo.get(Image, id)

    image
    |> Image.changeset(params)
    |> Repo.update()
  end

  def insert(image_params, listing_id) do
    %Image{}
    |> Image.changeset(Map.put(image_params, "listing_id", listing_id))
    |> Repo.insert()
  end
end
