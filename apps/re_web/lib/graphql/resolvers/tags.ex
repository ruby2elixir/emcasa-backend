defmodule ReWeb.Resolvers.Tags do
  @moduledoc """
  Resolvers for tags.
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.Tags

  def index(params, %{context: %{current_user: current_user}}) do
    tags =
      params
      |> Map.get(:filters, %{})
      |> Tags.filter(current_user)

    {:ok, tags}
  end

  def show(%{uuid: uuid}, %{context: %{current_user: current_user}}) do
    Tags.get(uuid, current_user)
  end

  def search(%{name: name}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :search, current_user, %{name: name}) do
      {:ok, Tags.search(name)}
    end
  end

  def per_listing(listing, _params, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Tags, :tags, listing)
    |> on_load(fn loader -> {:ok, Dataloader.get(loader, Tags, :tags, listing)} end)
  end

  def insert(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :insert, current_user, params) do
      Tags.insert(params)
    end
  end

  def update(%{uuid: uuid, input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :insert, current_user, params),
         {:ok, tag} <- Tags.get(uuid, current_user) do
      Tags.update(tag, params)
    end
  end
end
