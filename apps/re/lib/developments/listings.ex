defmodule Re.Developments.Listings do
  @moduledoc """
  Module to handle listings for developments (primary market) context.
  """
  alias Re.{
    Listing,
    PubSub,
    Repo
  }

  alias Ecto.Changeset

  def insert(params, opts) do
    %Listing{}
    |> changeset_for_opts(opts)
    |> Listing.development_changeset(params)
    |> Repo.insert()
  end

  def update(listing, params, opts) do
    changeset =
      listing
      |> changeset_for_opts(opts)
      |> Listing.development_changeset(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end

  defp changeset_for_opts(listing, opts) do
    Enum.reduce(opts, Changeset.change(listing), fn
      {:development, development}, changeset ->
        Changeset.change(changeset, %{development_uuid: development.uuid})

      {:address, address}, changeset ->
        Changeset.change(changeset, %{address_id: address.id})
    end)
  end

  def update_from_unit_params(listing, params) do
    changeset =
      listing
      |> Changeset.change(params)

    changeset
    |> Repo.update()
    |> PubSub.publish_update(changeset, "update_listing")
  end
end
