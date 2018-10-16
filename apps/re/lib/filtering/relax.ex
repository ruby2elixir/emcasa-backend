defmodule Re.Filtering.Relax do
  @moduledoc """
  Module to group logic to relax filter parameters
  """

  alias Re.{
    Filtering,
    Addresses.Neighborhoods
  }

  defguardp is_not_nil(value) when not is_nil(value)

  @types ~w(price area room neighborhoods garage_spots)a

  def apply(params) do
    Enum.reduce(@types, params, &do_apply/2)
  end

  def apply(params, _), do: params

  defp do_apply(:price, params) do
    params
    |> Filtering.cast()
    |> max_price()
    |> min_price()
  end

  defp do_apply(:area, params) do
    params
    |> Filtering.cast()
    |> max_area()
    |> min_area()
  end

  defp do_apply(:room, params) do
    params
    |> Filtering.cast()
    |> max_rooms()
    |> min_rooms()
  end

  defp do_apply(:garage_spots, params) do
    params
    |> Filtering.cast()
    |> max_garage_spots()
    |> min_garage_spots()
  end

  defp do_apply(:neighborhoods, params) do
    params
    |> Filtering.cast()
    |> neighborhoods()
  end

  defp do_apply(_, params), do: params

  defp max_price(%{max_price: max_price} = params) when is_not_nil(max_price) do
    %{params | max_price: trunc(max_price * 1.1)}
  end

  defp max_price(params), do: params

  defp min_price(%{min_price: min_price} = params) when is_not_nil(min_price) do
    %{params | min_price: trunc(min_price * 0.9)}
  end

  defp min_price(params), do: params

  defp max_garage_spots(%{max_garage_spots: max_garage_spots} = params)
       when is_not_nil(max_garage_spots) do
    %{params | max_garage_spots: max_garage_spots + 1}
  end

  defp max_garage_spots(params), do: params

  defp min_garage_spots(%{min_garage_spots: min_garage_spots} = params)
       when is_not_nil(min_garage_spots) do
    %{params | min_garage_spots: min_garage_spots - 1}
  end

  defp min_garage_spots(params), do: params

  defp max_area(%{max_area: max_area} = params) when is_not_nil(max_area) do
    %{params | max_area: trunc(max_area * 1.1)}
  end

  defp max_area(params), do: params

  defp min_area(%{min_area: min_area} = params) when is_not_nil(min_area) do
    %{params | min_area: trunc(min_area * 0.9)}
  end

  defp min_area(params), do: params

  defp max_rooms(%{max_rooms: max_rooms} = params) when is_not_nil(max_rooms) do
    %{params | max_rooms: max_rooms + 1}
  end

  defp max_rooms(params), do: params

  defp min_rooms(%{min_rooms: min_rooms} = params) when is_not_nil(min_rooms) do
    %{params | min_rooms: min_rooms - 1}
  end

  defp min_rooms(params), do: params

  defp neighborhoods(%{neighborhoods: neighborhoods} = params) when is_not_nil(neighborhoods) do
    relaxed_neighborhoods =
      neighborhoods
      |> Enum.map(&Neighborhoods.nearby/1)
      |> Enum.concat(neighborhoods)
      |> Enum.uniq()

    %{params | neighborhoods: relaxed_neighborhoods}
  end

  defp neighborhoods(params), do: params
end
