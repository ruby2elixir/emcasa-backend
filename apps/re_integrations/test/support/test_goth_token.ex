defmodule ReIntegrations.TestGoth.Token do
  def for_scope(scope),
    do:
      {:ok,
       %Goth.Token{
         account: :default,
         expires: 60_000,
         scope: scope,
         type: "Bearer",
         token: "test_token"
       }}
end
