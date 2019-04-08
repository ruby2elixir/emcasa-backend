defmodule ReWeb.Resolvers.Tags do
  @moduledoc """
  Resolvers for tags.
  """
  alias Re.Tags

  def index(_params, %{context: %{current_user: current_user}}) do
    tags =
      with :ok <- Bodyguard.permit(Tags, :fetch_all, current_user, nil) do
        Tags.all()
      else
        _ -> Tags.public()
      end

    {:ok, tags}
  end

  def search(%{name: name}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :search, current_user, %{name: name}) do
      {:ok, Tags.search(name)}
    end
  end

  def show(%{uuid: uuid}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :show, current_user, %{uuid: uuid}) do
      Tags.get(uuid)
    else
      _ -> Tags.get_public(uuid)
    end
  end

  def insert(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :insert, current_user, params) do
      Tags.insert(params)
    end
  end

  def update(%{uuid: uuid, input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Tags, :insert, current_user, params),
         {:ok, tag} <- Tags.get(uuid) do
      Tags.update(tag, params)
    end
  end
end
