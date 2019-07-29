defmodule ReIntegrations.Salesforce.Payload.Event do
  @moduledoc """
  Module for validating salesforce event entity
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  defenum(Field,
    id: "Id",
    who_id: "WhoId",
    what_id: "WhatId",
    owner_id: "OwnerId",
    subject: "Subject",
    type: "Type",
    location: "Location",
    description: "Description",
    start: "StartDateTime",
    end: "EndDateTime",
    duration: "DurationInMinutes"
  )

  defenum(SubjectType,
    tour_session: "Visita para Tour",
    photography_session: "Visita para Fotos"
  )

  defenum(EventType,
    visit: "Visita"
  )

  @primary_key {:id, :string, []}

  schema "salesforce_event" do
    field :who_id, :string
    field :what_id, :string
    field :owner_id, :string
    field :subject, SubjectType
    field :type, EventType
    field :location, :string
    field :description, :string
    field :start, :naive_datetime
    field :end, :naive_datetime
    field :duration, :integer
  end

  @params ~w(who_id what_id owner_id subject type location description start end duration)a
  @required_params ~w(subject start end)a

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
    |> validate_required(@required_params)
  end
end

defimpl Jason.Encoder, for: ReIntegrations.Salesforce.Payload.Event do
  alias ReIntegrations.Salesforce.Payload.Event

  def encode(value, opts) do
    value
    |> Map.take(Event.Fields.__valid_values__())
    |> Enum.reduce(%{}, &reduce_field/2)
    |> Jason.Encode.map(opts)
  end

  defp reduce_field({:subject, enum}, acc) when is_atom(enum),
    do:
      with({:ok, value} <- Event.SubjectType.dump(enum), do: reduce_field({:subject, value}, acc))

  defp reduce_field({:type, enum}, acc) when is_atom(enum),
    do: with({:ok, value} <- Event.EventType.dump(enum), do: reduce_field({:type, value}, acc))

  defp reduce_field({key, value}, acc),
    do: with({:ok, field} <- Event.Field.dump(key), do: Map.put(acc, field, value))
end
