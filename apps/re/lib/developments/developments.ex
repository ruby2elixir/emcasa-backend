defmodule Re.Developments do
  @moduledoc """
  Context for developments.
  """
  @behaviour Bodyguard.Policy

  require Ecto.Query

  alias Ecto.{
    Changeset,
    Multi
  }

  alias Re.{
    Development,
    Developments.JobQueue,
    Developments.Queries,
    Repo
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def data(params), do: Dataloader.Ecto.new(Re.Repo, query: &query/2, default_params: params)

  def query(_query, _args), do: Re.Development

  def all do
    Re.Development
    |> Re.Repo.all()
  end

  def get(uuid), do: do_get(Development, uuid)

  def get_by_orulo_id(orulo_id) do
    case Repo.get_by(Development, orulo_id: orulo_id) do
      nil -> {:error, :not_found}
      development -> {:ok, development}
    end
  end

  def get_preloaded(uuid, preload),
    do: do_get(Queries.preload_relations(Development, preload), uuid)

  defp do_get(query, uuid) do
    case Repo.get(query, uuid) do
      nil -> {:error, :not_found}
      development -> {:ok, development}
    end
  end

  def insert(params, address), do: do_insert(params, address)

  defp do_insert(params, address) do
    %Re.Development{}
    |> Changeset.change(address_id: address.id)
    |> Development.changeset(params)
    |> Repo.insert()
  end

  def preload(development, preload), do: Re.Repo.preload(development, preload)

  def update(%{uuid: uuid} = development, params, address) do
    changeset =
      development
      |> Changeset.change(address_id: address.id)
      |> Development.changeset(params)

    Multi.new()
    |> JobQueue.enqueue(:mirror_job, %{
      "type" => "mirror_update_development_to_listings",
      "uuid" => uuid
    })
    |> Multi.update(:update_development, changeset)
    |> Repo.transaction()
    |> extract_transaction()
  end

  defp extract_transaction({:ok, %{update_development: update_development}}),
    do: {:ok, update_development}

  defp extract_transaction({:error, _, changeset, _}), do: {:error, changeset}
end
