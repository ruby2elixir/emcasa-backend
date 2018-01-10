defmodule Re.Images.Policy do

  def authorize(_, %{role: "admin"}, _), do: :ok
  def authorize(_, nil, _), do: {:error, :unauthorized}
  def authorize(_, _, _), do: {:error, :forbidden}

end
