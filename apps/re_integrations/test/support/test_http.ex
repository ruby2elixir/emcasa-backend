defmodule ReIntegrations.TestHTTP do
  @moduledoc false

  def get(%URI{path: "/buildings/666"}, _) do
    {:ok, %{body: "{\"test\": \"building_payload\"}"}}
  end

  def get(%URI{path: "/buildings/666/images"}, _) do
    {:ok, %{body: "{\"test\": \"images_payload\"}"}}
  end

  def get(%URI{path: "/buildings/666/typologies"}, _) do
    {:ok, %{body: "{\"test\": \"typologies_payload\"}"}}
  end

  def get(%URI{path: "/buildings/1/typologies/1/units"}, _) do
    {:ok, %{body: "{\"units\": []}"}}
  end

  def get(%URI{path: "/buildings/1/typologies/2/units"}, _) do
    {:ok, %{body: "{\"units\": []}"}}
  end

  def get(%URI{path: "/jobs/INVALID_JOB_ID"}, _opts),
    do: {:ok, %{status_code: 404}}

  def get(%URI{path: "/jobs/FINISHED_JOB_ID"}, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
           {
             "status": "finished",
             "output": {
               "unserved": null,
               "solution": {}
             }
           }
         """
       }}

  def get(%URI{path: "/jobs/PENDING_JOB_ID"}, _opts),
    do: {:ok, %{status_code: 200, body: "{\"status\": \"pending\"}"}}

  def get(%URI{path: "/jobs/FAILED_JOB_ID"}, _opts),
    do: {:ok, %{status_code: 412, body: "{\"status\": \"error\", \"output\": \"error message\"}"}}

  def get(%URI{path: "/simulator"}, [], _opts),
    do: {:ok, %{body: "{\"cem\":\"10,8%\",\"cet\":\"11,3%\"}"}}

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

  def post(%URI{path: "/v1/vrp-long"}, _body, _opts),
    do: {:ok, %{body: "{\"job_id\": \"100\"}"}}

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
                "Faixa_Hor_ria_Tour__c": "Manhã: 09h - 12h"
              },
              {
                "Id": "0x02",
                "AccountId": "0x01",
                "OwnerId": "0x01",
                "Bairro__c": "Vila Mariana",
                "Dados_do_Imovel_para_Venda__c": "address 123",
                "Data_Tour__c": "2019-07-29T20:25:32.000Z"
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
