defmodule ReIntegrations.Salesforce.Payload.Event do
  @moduledoc """
  Module for validating priceteller input parameters
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  defenum SubjectType,
    tour_session: "Visita para Tour",
    photography_session: "Visita para Fotos"

  defenum EventType,
    visit: "Visita"

  schema "salesforce_event" do
    field :WhoId, :string
    field :WhatId, :string
    field :OwnerId, :string
    field :Subject, SubjectType
    field :Type, EventType
    field :Location, :string
    field :Description, :string
    field :StartDateTime, :naive_datetime
    field :EndDateTime, :naive_datetime
    field :DurationInMinutes, :integer
  end

  @params ~w(WhoId WhatId OwnerId Subject Type Location Description
             StartDateTime EndDateTime DurationInMinutes)a
  @required_params ~w(Subject StartDateTime EndDateTime)a
  @enum_fields ~w(Subject Type)a

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, changeset.changes}
      changeset -> {:error, :invalid_input, params, changeset}
    end
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> update_enums(@enum_fields)
  end

  defp update_enums(struct, fields),
    do: Enum.reduce(fields, struct, fn field, acc -> update_enum(acc, field) end)

  defp update_enum(struct, field) do
    enum = __MODULE__.__schema__(:type, field).__enum_map__()
    struct
    |> update_change(field, &Keyword.get(enum, &1))
  end
end
