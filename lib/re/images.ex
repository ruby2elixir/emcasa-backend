defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """

  import Ecto.Query

  alias Re.{Repo, Image}

  def all(listing_id) do
    Repo.all(from i in Image,
      where: i.listing_id == ^listing_id,
      preload: :listing)
  end
end
