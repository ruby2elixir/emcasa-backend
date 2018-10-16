defmodule ReWeb.InterestTypeControllerTest do
  use ReWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "all interest types", %{conn: conn} do
      conn = get(conn, interest_type_path(conn, :index))

      response = json_response(conn, 200)

      assert [
               %{"id" => _, "name" => "Me ligue dentro de 5 minutos"},
               %{"id" => _, "name" => "Me ligue em um horário específico"},
               %{"id" => _, "name" => "Agendamento por e-mail"},
               %{"id" => _, "name" => "Agendamento por Whatsapp"}
             ] = response["data"]
    end
  end
end
