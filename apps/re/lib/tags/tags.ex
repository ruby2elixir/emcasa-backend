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

  def all(%{role: "admin"}) do
    Tag
    |> Repo.all()
  end

  def all(_) do
    %{visibility: "public"}
    |> Queries.filter_by()
    |> Repo.all()
  end

  def search(name) do
    %{name_slug_like: Slugs.sluggify(name)}
    |> Queries.filter_by()
    |> Repo.all()
  end

  def get(uuid, %{role: "admin"}) do
    case Repo.get(Tag, uuid) do
      nil -> {:error, :not_found}
      tag -> {:ok, tag}
    end
  end

  def get(uuid, _) do
    tag =
      %{uuid: uuid, visibility: "public"}
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
