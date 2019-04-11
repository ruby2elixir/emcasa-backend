defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """
  @behaviour Bodyguard.Policy

  alias Re.{
    Image,
    Images.DataloaderQueries,
    Images.Queries,
    Listings,
    Repo
  }

  alias Ecto.Changeset

  @http Application.get_env(:re_integrations, :http, HTTPoison)

  defdelegate authorize(action, user, params), to: Re.Images.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(query, args), do: DataloaderQueries.build(query, args)

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

  def insert(image_params, association) do
    %Image{}
    |> Image.create_changeset(image_params)
    |> change_association(association)
    |> Changeset.change(%{
      is_active: true,
      position: calculate_position(association)
    })
    |> Repo.insert()
  end

  defp change_association(changeset, %Re.Listing{} = listing),
    do: Changeset.change(changeset, listing: listing)

  defp change_association(changeset, %Re.Development{} = development),
    do: Changeset.change(changeset, development: development)

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

  def get_list(inputs) do
    inputs
    |> Enum.map(&do_get/1)
    |> Enum.split_with(fn
      {:ok, _, _} -> true
      {:error, :not_found, _} -> false
    end)
    |> case do
      {images, []} -> {:ok, images}
      {_, some_not_found} -> {:error, "Some images were not found. Inputs: #{some_not_found}"}
    end
  end

  def list_by_ids(ids) do
    ids
    |> Queries.with_ids()
    |> Repo.all()
  end

  defp do_get(input) do
    case Repo.get(Image, input.id) do
      nil -> {:error, :not_found, input}
      image -> {:ok, image, input}
    end
  end

  def fetch_listing(images) do
    case Enum.uniq_by(images, fn %{listing_id: id} -> id end) do
      [%{listing_id: listing_id}] -> Listings.get(listing_id)
      _ -> {:error, :distinct_listings}
    end
  end

  def update_images(images_and_inputs), do: {:ok, Enum.map(images_and_inputs, &do_update_image/1)}

  defp do_update_image({:ok, image, input}) do
    image
    |> Image.update_changeset(input)
    |> Repo.update()
    |> case do
      {:ok, image} -> image
      {:error, error} -> error
    end
  end

  def deactivate_images(images) do
    ids = Enum.map(images, fn %{id: id} -> id end)

    Image
    |> Queries.with_ids(ids)
    |> Repo.update_all(set: [is_active: false])
    |> case do
      {_, nil} -> {:ok, images}
      error -> error
    end
  end

  def activate_images(images) do
    ids = Enum.map(images, fn %{id: id} -> id end)

    Image
    |> Queries.with_ids(ids)
    |> Repo.update_all(set: [is_active: true])
    |> case do
      {_, nil} -> {:ok, images}
      error -> error
    end
  end

  def deactivate(image) do
    image
    |> Image.deactivate_changeset(%{is_active: false})
    |> Repo.update()
  end

  def zip(listing) do
    dir_name = "./temp/listing-#{listing.id}/"

    File.mkdir_p(dir_name)

    listing
    |> Map.get(:images)
    |> Enum.map(&download_image(&1, dir_name))
    |> Enum.map(&wait_download(&1))
    |> create_zip(dir_name)
  end

  defp download_image(%{filename: filename}, dir_name) do
    Task.async(fn ->
      {:ok, %{body: body}} =
        @http.get("https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/#{filename}")

      :ok = File.write(dir_name <> "#{filename}", body)
      filename
    end)
  end

  defp wait_download(image), do: Task.await(image)

  defp create_zip(files, dir_name) do
    charlist_files = Enum.map(files, &String.to_charlist/1)
    :zip.create(dir_name <> "images.zip", charlist_files, cwd: dir_name)
  end
end
