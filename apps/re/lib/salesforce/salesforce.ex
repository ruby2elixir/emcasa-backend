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

  def get_opportunity_with_with_associations(id) do
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

  def flatten_map(object) do
    object
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      case key do
        "attributes" -> acc
        _ -> resolve_flatten(acc, key, value)
      end
    end)
  end

  defp resolve_flatten(map, key, value) when is_bitstring(value), do: Map.put(map, key, value)

  defp resolve_flatten(map, key, value) when is_map(value) do
    value
    |> Enum.reduce(map, fn {nested_key, nested_value}, acc ->
      case nested_key do
        "attributes" -> acc
        _ -> Map.put(acc, key <> nested_key, nested_value)
      end
    end)
  end
end
