defmodule Re.Shortlists.Salesforce.Opportunity do
  @moduledoc """
  Module for validating salesforce opportunity entity on shortlist context
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  @primary_key {:id, :string, []}

  defenum(Schema,
    infra: "Infraestrutura__c",
    type: "Tipo_do_Imovel__c",
    rooms: "Quantidade_Minima_de_Quartos__c",
    suites: "Quantidade_MInima_de_SuItes__c",
    bathrooms: "Quantidade_Minima_de_Banheiros__c",
    floor: "Andar_de_Preferencia__c",
    elevators: "Necessita_Elevador__c",
    area: "Area_Desejada__c",
    subway: "Proximidade_de_Metr__c",
    garage_spots: "Numero_Minimo_de_Vagas__c",
    neighborhood: "Bairros_de_Interesse__c",
    price: "Valor_M_ximo_para_Compra_2__c",
    maintenance_fee: "Valor_M_ximo_de_Condom_nio__c",
    lobby: "Portaria_2__c"
  )

  schema "salesforce_opportunity" do
    field :infra, :string
    field :type, :string
    field :rooms, :string
    field :suites, :string
    field :bathrooms, :string
    field :floor, :string
    field :elevators, :string
    field :area, :string
    field :subway, :string
    field :garage_spots, :string
    field :neighborhood, :string
    field :price, :string
    field :maintenance_fee, :string
    field :lobby, :string
  end

  @params ~w(infra type rooms suites bathrooms floor elevators area subway garage_spots neighborhood
  price maintenance_fee lobby)a

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, apply_changes(changeset)}
      changeset -> {:error, :invalid_input, params, changeset}
    end
  end

  def build(payload) do
    payload
    |> Map.take(Schema.__valid_values__())
    |> Enum.into(%{}, &build_field/1)
    |> validate()
  end

  defp build_field({field, value}),
    do: with({:ok, key} <- Schema.cast(field), do: {key, value})

  defp changeset(struct, params), do: cast(struct, params, @params)
end
