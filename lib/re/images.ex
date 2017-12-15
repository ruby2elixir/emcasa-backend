defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """

  import Ecto.Query

  alias Re.{
    Image,
    Listing,
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

end
