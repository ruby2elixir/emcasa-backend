defmodule Re.TestHTTP do
  @moduledoc false

  def get("https://res.cloudinary.com/emcasa/image/upload/f_auto/v1513818385/" <> filename), do: {:ok, %{body: filename}}

end
