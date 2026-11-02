defmodule FuelCalculator.Flight.Action do
  @moduledoc """
  Module for flight step actions and their fuel formulas.
  """

  @formulas [launch: {"0.042", 33}, land: {"0.033", 42}]

  @type t :: :launch | :land

  @spec all() :: [t()]
  def all, do: Keyword.keys(@formulas)

  @doc """
  Returns the multiplier and the minus of the action's fuel formula
  `mass * gravity * multiplier - minus`.

      iex> FuelCalculator.Flight.Action.formula(:land)
      {Decimal.new("0.033"), Decimal.new("42")}

  """
  @spec formula(t()) :: {Decimal.t(), Decimal.t()}
  def formula(action) do
    {multiplier, minus} = Keyword.fetch!(@formulas, action)

    {Decimal.new(multiplier), Decimal.new(minus)}
  end
end
