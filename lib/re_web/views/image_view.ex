defmodule ReWeb.ImageView do
  use ReWeb, :view

  def render("image.json", %{image: image}) do
    %{id: image.id,
      filename: image.filename,
      position: image.position}
  end
end
