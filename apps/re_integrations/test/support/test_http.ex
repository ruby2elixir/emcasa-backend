defmodule ReIntegrations.TestHTTP do
  @moduledoc false

  def post(%URI{path: "/priceteller"}, _, [
        {"Content-Type", "application/json"},
        {"X-Api-Key", "mahtoken"}
      ]),
      do:
        {:ok,
         %{
           body:
             "{" <>
               "\"listing_price\":632868.63," <>
               "\"listing_price_rounded\":635000.0," <>
               "\"sale_price\":575910.45," <>
               "\"sale_price_rounded\":575000.0}"
         }}

  def post(%URI{path: "/api/v1/query"}, body, _opts) do
    if String.contains?(body, "FROM Opportunity") do
      {
        :ok,
        %{
          status_code: 200,
          body: """
          {
            "records": [
              {
                "Id": "0x01",
                "AccountId": "0x01",
                "OwnerId": "0x01",
                "Bairro__c": "Vila Mariana",
                "Dados_do_Imovel_para_Venda__c": "address 123",
                "Periodo_Disponibilidade_Tour__c": "Manhã"
              },
              {
                "Id": "0x02",
                "AccountId": "0x01",
                "OwnerId": "0x01",
                "Bairro__c": "Vila Mariana",
                "Dados_do_Imovel_para_Venda__c": "address 123",
                "Data_Fixa_para_o_Tour__c": "2019-07-29",
                "Horario_Fixo_para_o_Tour__c": "20:25:00",
                "Periodo_Disponibilidade_Tour__c": "Fixo"
              }
            ]
          }
          """
        }
      }
    else
      {:ok, %{status_code: 400}}
    end
  end
end
