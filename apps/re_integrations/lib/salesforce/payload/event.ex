defmodule ReIntegrations.Salesforce.Payload.Event do
  @moduledoc """
  Module for validating salesforce event entity
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  defenum(Type,
    visit: "Visita"
  )

  @primary_key {:id, :string, []}

  @doc """
  Maps salesforce fields to atoms for internal use
  """
  defenum(Schema,
    id: "Id",
    owner_id: "OwnerId",
    who_id: "WhoId",
    what_id: "WhatId",
    type: "Type",
    subject: "Subject",
    description: "Description",
    address: "Location",
    duration: "DurationInMinutes",
    start: "StartDateTime",
    end: "EndDateTime"
  )

  schema "salesforce_event" do
    field :account_id, :string
    field :owner_id, :string
    field :who_id, :string
    field :what_id, :string
    field :type, Type
    field :subject, :string
    field :description, :string
    field :address, :string
    field :duration, :integer
    field :start, :naive_datetime
    field :end, :naive_datetime
  end

  @params ~w(id owner_id who_id what_id type subject description address duration start end)a
  @required ~w(type subject duration start end)a

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, apply_changes(changeset)}
      changeset -> {:error, :invalid_input, params, changeset}
    end
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
  end
end

defimpl Jason.Encoder, for: ReIntegrations.Salesforce.Payload.Event do
  alias ReIntegrations.Salesforce.Payload.Event

  def encode(value, opts) do
    keys = Keyword.keys(Event.Schema.__enum_map__())

    value
    |> Map.take(keys)
    |> Map.drop([:id])
    |> Enum.into(%{}, &dump_field/1)
    |> Jason.Encode.map(opts)
  end

  defp dump_field({:type, enum}) when is_atom(enum),
    do: with({:ok, value} <- Event.Type.dump(enum), do: dump_field({:type, value}))

  defp dump_field({key, value}),
    do: with({:ok, field} <- Event.Schema.dump(key), do: {field, value})
end
