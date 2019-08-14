defmodule Re.TestHTTP do
  @moduledoc false

  def get(%URI{host: "graph.facebook.com"}),
    do:
      {:ok,
       %{
         body:
           "{\"created_time\":\"2010-01-01T10:00:00+0000\",\"id\":\"12345\",\"field_data\":[{\"name\":\"full_name\",\"values\":[\"mah name\"]},{\"name\":\"phone_number\",\"values\":[\"+5511999999999\"]},{\"name\":\"qual_o_seu_objetivo?\",\"values\":[\"quero_comprar_um_imóvel\"]},{\"name\":\"qual_região_vocêa_tem_interesse?\",\"values\":[\"outros_(zona_norte)\"]},{\"name\":\"email\",\"values\":[\"admin@emcasa.com\"]}],\"retailer_item_id\":\"1\"}"
       }}

  def get("https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename),
    do: {:ok, %{body: filename}}

  def post(%URI{path: "/api/v1/Lead"}, _body, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
         {
           "id": "0x01",
           "success": true,
           "errors": []
         }
         """
       }}

  def patch(%URI{path: "/api/v1/Lead/0x01"}, _body, _opts),
    do:
      {:ok,
       %{
         status_code: 200,
         body: """
         {
           "id": "0x01",
           "success": true,
           "errors": []
         }
         """
       }}
end
