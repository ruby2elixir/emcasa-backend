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
             "input": {
               "visits": {
                 "1": {"notes": "", "customNotes": {"account_id":"0x01", "owner_id":"0x01"}},
                 "2": {"notes": "", "customNotes": {"account_id":"0x01", "owner_id":"0x01"}}
               },
               "fleet": {},
               "options": {"date": "2019-08-01T20:03:48.347904Z"}
             },
             "output": {
               "unserved": null,
               "solution": {
                  "affb1f63-399a-4d85-9f65-c127994104f6": [
                    {
                      "location_id": "depot",
                      "location_name": "depot",
                      "arrival_time": "08:00"
                    },
                    {
                      "location_id": "2",
                      "location_name": "Rua Vergueiro, 3475",
                      "arrival_time": "08:10",
                      "finish_time": "08:40"
                    },
                    {
                      "location_id": "1",
                      "location_name": "R. Francisco Cruz, 345",
                      "arrival_time": "08:41",
                      "finish_time": "09:11"
                    }
                  ]
               }
             }
           }
         """
       }}

  def get(%URI{path: "/jobs/PENDING_JOB_ID"}, _opts),
    do: {:ok, %{status_code: 200, body: "{\"status\": \"pending\"}"}}

  def get(%URI{path: "/jobs/FAILED_JOB_ID"}, _opts),
    do: {:ok, %{status_code: 412, body: "{\"status\": \"error\", \"output\": \"error message\"}"}}

  def get(%URI{path: "/api/v1/User/0x01"}, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
         {
           "Id": "0x01",
           "Name": "name"
         }
         """
       }}

  def get(%URI{path: "/api/v1/Account/0x01"}, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
         {
           "Id": "0x01",
           "Name": "name",
           "PersonMobilePhone": ""
         }
         """
       }}

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

  def post(%URI{path: "/api/v1/Event"}, _body, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
         {
           "Id": "0x01",
           "AccountId": "0x01",
           "OwnerId": "0x01",
           "WhoId": "0x01",
           "WhatId": "0x01",
           "Type": "Event",
           "Subject": "some subject",
           "Description": "some description",
           "Location": "some location",
           "DurationInMinutes": 60,
           "StartDateTime": "2019-08-01T21:00:00.000+0000",
           "EndDateTime": "2019-08-01T21:00:00.000+0000"
         }
         """
       }}

  def patch(%URI{path: "/api/v1/Opportunity/0x01"}, _body, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
         {
           "Id": "0x01"
         }
         """
       }}
end
