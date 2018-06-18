defmodule ReWeb.Resolvers.Images do
  @moduledoc """
  Resolver module for images
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def per_listing(listing, params, %{context: %{loader: loader, current_user: current_user}}) do
    is_admin? = is_admin(listing, current_user)

    loader
    |> Dataloader.load(
      Re.Images,
      {:images, Map.put(params, :has_admin_rights, is_admin?)},
      listing
    )
    |> on_load(fn loader ->
      images =
        loader
        |> Dataloader.get(
          Re.Images,
          {:images, Map.put(params, :has_admin_rights, is_admin?)},
          listing
        )
        |> limit(params)

      {:ok, images}
    end)
  end

  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false

  defp limit(images, %{limit: limit}), do: Enum.take(images, limit)
  defp limit(images, _), do: images
end
