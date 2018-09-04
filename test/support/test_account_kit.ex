defmodule Re.TestAccountKit do

  def me("valid_access_token") do
    {:ok,
      %{"application" => %{"id" => "123"},
      "id" => "321",
      "phone" => %{
        "number" => "+5511999999999"
    }}}
  end

  def me(_) do
    {:error, %{"message" => "Invalid OAuth access token.", "code" => 190}}
  end

end
