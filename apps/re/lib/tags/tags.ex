defmodule Re.Tags do
  @moduledoc """
  Context for tags.
  """
  @behaviour Bodyguard.Policy

  require Ecto.Query

  alias Re.{
    Tag,
    Tags.Queries,
    Repo,
    Slugs
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Tag

  def all do
    Tag
    |> Repo.all()
  end

  def public do
    Queries.public()
    |> Repo.all()
  end

  def search(name) do
    Slugs.sluggify(name)
    |> Queries.match_slug()
    |> Repo.all()
  end

  def get(id) do
    case Repo.get(Tag, id) do
      nil -> {:error, :not_found}
      tag -> {:ok, tag}
    end
  end

  def list_by_uuids(uuids) do
    uuids
    |> Queries.with_uuids()
    |> Repo.all()
  end

  def list_by_slugs(slugs) do
    slugs
    |> Queries.with_slugs()
    |> Repo.all()
  end

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
