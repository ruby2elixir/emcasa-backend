defmodule ReWeb.GraphQL.Middlewares.ErrorHandler do
  @moduledoc """
  Module for handling errors
  """
  @behaviour Absinthe.Middleware

  def call(resolution, _arg) do
    %{resolution | errors: Enum.reduce(resolution.errors, [], &handle_error/2)}
  end

  defp handle_error(:not_found, errors), do: [%{message: "Not found", code: 404} | errors]

  defp handle_error(%Ecto.Changeset{} = changeset, errors) do
    changeset_errors =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.map(fn {k, v} -> %{message: "#{k}: #{v}", code: 422} end)

    changeset_errors ++ errors
  end

  defp handle_error(:bad_request, errors), do: [%{message: "Bad request", code: 400} | errors]

  defp handle_error(:unauthorized, errors), do: [%{message: "Unauthorized", code: 401} | errors]

  defp handle_error(:forbidden, errors), do: [%{message: "Forbidden", code: 403} | errors]

  defp handle_error(:street_not_covered, errors),
    do: [%{message: "Street not covered", code: 422} | errors]

  defp handle_error(error, errors), do: [error | errors]
end
