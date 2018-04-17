defmodule ReWeb.ImageView do
  use ReWeb, :view

  def render("index.json", %{images: images}) do
    %{images: render_many(images, ReWeb.ImageView, "image.json")}
  end

  def render("create.json", %{image: image}) do
    %{image: render_one(image, ReWeb.ImageView, "image.json")}
  end

  def render("image.json", %{image: image}) do
    %{id: image.id, filename: image.filename, position: image.position, description: image.description}
  end
end
