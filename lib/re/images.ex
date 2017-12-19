defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """

  import Ecto.Query

  alias Re.{
    Listing,
    Image,
    Repo
  }

  @query from l in Listing, preload: :images

  def all(%{"listing_id" => listing_id}) do
    @query
    |> Repo.get(listing_id)
    |> Map.get(:images)
    |> format_output()
  end
  def all(_), do: {:error, :bad_request}

  defp format_output(images), do: {:ok, images}

  def update_per_listing(_listing, images_param) do
    Enum.each(images_param, &update_image/1)
  end

  defp update_image(%{"id" => id} = params) do
    image = Repo.get(Image, id)

    image
    |> Image.changeset(params)
    |> Repo.update()
  end

end
