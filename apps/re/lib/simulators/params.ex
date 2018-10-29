defmodule Re.Simulators.Credipronto.Params do
  @moduledoc """
  Module for grouping credipronto simulator query params
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "simulator_credipronto_params" do
    field :mutuary, :string
    field :birthday, :date
    field :include_coparticipant, :boolean
    field :net_income, :decimal
    field :net_income_coparticipant, :decimal
    field :birthday_coparticipant, :date
    field :product_type, :string, default: "F"
    field :listing_type, :string, default: "R"
    field :listing_price, :decimal
    field :insurer, :string, default: "itau"
    field :amortization, :boolean, default: true
    field :fundable_value, :decimal
    field :evaluation_rate, :decimal
    field :term, :integer
    field :calculate_tr, :boolean, default: false
    field :itbi_value, :decimal
    field :annual_interest, :float
    field :home_equity_annual_interest, :float
    field :rating, :integer, default: 2
    field :sum, :boolean, default: true
    field :download_pdf, :boolean, default: false
    field :send_email, :boolean, default: false
    field :email, :string
  end

  @optional ~w(birthday_coparticipant net_income_coparticipant
               home_equity_annual_interest download_pdf send_email email)a

  @required ~w(mutuary birthday include_coparticipant net_income product_type listing_type
               listing_price insurer amortization fundable_value evaluation_rate term calculate_tr
               itbi_value annual_interest rating sum)a

  @mutuary_options ~w(PF PJ)
  @product_types ~w(F H)
  @listing_types ~w(R C)
  @insurer_options ~w(itau tokio)
  @amortization_options ~w(S P)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional ++ @required)
    |> validate_required(@required)
    |> validate_inclusion(:mutuary, @mutuary_options, message: "should be one of: [#{Enum.join(@mutuary_options, " ")}]")
    |> validate_inclusion(:product_type, @product_types, message: "should be one of: [#{Enum.join(@product_types, " ")}]")
    |> validate_inclusion(:listing_type, @listing_types, message: "should be one of: [#{Enum.join(@listing_types, " ")}]")
    |> validate_inclusion(:insurer, @insurer_options, message: "should be one of: [#{Enum.join(@insurer_options, " ")}]")
    |> validate_inclusion(:amortization, @amortization_options, message: "should be one of: [#{Enum.join(@amortization_options, " ")}]")
    |> validate_required_if(:include_coparticipant, :birthday_coparticipant)
    |> validate_required_if(:include_coparticipant, :net_income)
  end

  defp validate_required_if(changeset, toggle_field, opt_field) do
    case get_field(changeset, toggle_field) do
      nil -> changeset
      false -> changeset
      true -> validate_required(changeset, opt_field)
    end
  end
end
