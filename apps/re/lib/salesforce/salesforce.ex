defmodule Re.Salesforce do
  @moduledoc """
  Context module for salesforce
  """

  alias Re.Salesforce.Client

  @opportunity_params ~w(Infraestrutura__c Tipo_do_Imovel__c Quantidade_Minima_de_Quartos__c
  Quantidade_MInima_de_SuItes__c Quantidade_Minima_de_Banheiros__c Numero_Minimo_de_Vagas__c
  Area_Desejada__c Andar_de_Preferencia__c Necessita_Elevador__c Proximidade_de_Metr__c
  Bairros_de_Interesse__c Valor_M_ximo_para_Compra_2__c Valor_M_ximo_de_Condom_nio__c Portaria_2__c
  Account.Name Owner.Name)

  def get_opportunity_with_associations(id) do
    query = """
    SELECT #{Enum.join(@opportunity_params, ", ")}
    FROM Opportunity
    WHERE
      Id = '#{id}'
    ORDER BY CreatedDate ASC
    """

    query(query)
  end

  defp query(query) do
    with {:ok, %{status_code: 200, body: body}} <- Client.query(query),
         {:ok, %{"records" => [record]}} <- Jason.decode(body),
         {:ok, entity} <- flatten_map(record) do
      {:ok, entity}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      error -> error
    end
  end

  def flatten_map(object), do: Enum.reduce(object, %{}, &resolve_flatten/2)

  defp resolve_flatten({"attributes", _value}, map), do: map

  defp resolve_flatten({key, value}, map) when is_bitstring(value), do: Map.put(map, key, value)

  defp resolve_flatten({key, value}, map) when is_map(value),
    do: Enum.reduce(value, map, &create_new_key(&1, &2, key))

  defp create_new_key({"attributes", _nested_value}, map, _root_key), do: map

  defp create_new_key({nested_key, nested_value}, map, root_key) do
    Map.put(map, root_key <> nested_key, nested_value)
  end
end
