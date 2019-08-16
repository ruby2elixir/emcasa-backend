defmodule ReWeb.GraphQL.Shortlists.QueryTest do
  use ReWeb.ConnCase

  import Mockery
  import Re.Factory

  alias ReWeb.AbsintheHelpers

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  @tag dev: true
  test "should return listings with relaxed filters for admin", %{admin_conn: conn} do
    mock(
      HTTPoison,
      :get,
      {:ok,
       %{
         body:
           "{\"Infraestrutura__c\":\"Indiferente;Sacada;Churrasqueira\",\"Tipo_do_Imovel__c\":\"Apartamento\",\"Quantidade_Minima_de_Quartos__c\":\"1\",\"Quantidade_MInima_de_SuItes__c\":\"1\",\"Quantidade_Minima_de_Banheiros__c\":\"1\",\"Numero_Minimo_de_Vagas__c\":\"1\",\"Area_Desejada__c\":\"A partir de 60m²\",\"Andar_de_Preferencia__c\":\"Alto\",\"Necessita_Elevador__c\":\"Indiferente\",\"Proximidade_de_Metr__c\":\"Sim\",\"Bairros_de_Interesse__c\":\"Botafogo;Urca\",\"Valor_M_ximo_para_Compra_2__c\":\"De R$750.000 a R$1.000.000\",\"Valor_M_ximo_de_Condom_nio__c\":\"R$800 a R$1.000\",\"Portaria_2__c\":\"Indiferente\"}"
       }}
    )

    %{id: listing_id} = insert(:listing, rooms: 3)

    variables = %{
      "opportunityId" => "0x01"
    }

    query = """
      query ShortlistListings ($opportunityId: String) {
        shortlistListings (opportunityId: $opportunityId) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_wrapper(query, variables))

    IO.inspect(json_response(conn, 200))

    assert [%{"id" => to_string(listing_id)}] ==
             json_response(conn, 200)["data"]["shortlistListings"]
  end
end
