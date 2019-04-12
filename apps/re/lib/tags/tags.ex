defmodule Re.Tags do
  @moduledoc """
  Context for tags.
  """
  @behaviour Bodyguard.Policy

  require Ecto.Query

  alias Re.{
    Tag,
    Tags.DataloaderQueries,
    Tags.Queries,
    Repo,
    Slugs
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(query, args), do: DataloaderQueries.build(query, args)

  def all(user) do
    %{}
    |> query_visibility(user)
    |> Queries.filter_by()
    |> Repo.all()
  end

  def search(name) do
    %{name_slug_like: Slugs.sluggify(name)}
    |> Queries.filter_by()
    |> Repo.all()
  end

  def filter(params, user) do
    params
    |> query_visibility(user)
    |> Queries.filter_by()
    |> Repo.all()
  end

  def get(uuid, user) do
    tag =
      %{uuid: uuid}
      |> query_visibility(user)
      |> Queries.filter_by()
      |> Repo.one()

    case tag do
      nil -> {:error, :not_found}
      tag -> {:ok, tag}
    end
  end

  def list_by_uuids(uuids) do
    %{uuids: uuids}
    |> Queries.filter_by()
    |> Repo.all()
  end

  def list_by_slugs(slugs) do
    %{name_slugs: slugs}
    |> Queries.filter_by()
    |> Repo.all()
  end

  defp query_visibility(params, %{role: "admin"}), do: params
  defp query_visibility(params, _), do: Map.merge(params, %{visibility: "public"})

  def insert(params) do
    %Tag{}
    |> Tag.changeset(params)
    |> Repo.insert()
  end

  def update(tag, params) do
    tag
    |> Tag.changeset(params)
    |> Repo.update()
  end
end
