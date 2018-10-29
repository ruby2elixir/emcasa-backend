defmodule ReIntegrations.TestHTTP do
  @moduledoc false

  def get("https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename),
    do: {:ok, %{body: filename}}

  def get(%URI{path: "/simulator"}, [], _opts),
    do: {:ok, %{body: "{\"cem\":\"10,8%\",\"cet\":\"11,3%\"}"}}
end
