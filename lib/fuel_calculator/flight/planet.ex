defmodule FuelCalculator.Flight.Planet do
  @moduledoc """
  Planets a mission can launch from or land on, with their surface gravity.
  """

  # In the order they are offered to the user, gravity in m/s².
  @gravity [earth: "9.807", moon: "1.62", mars: "3.711"]

  @type t :: :earth | :moon | :mars

  @spec all() :: [t()]
  def all, do: Keyword.keys(@gravity)

  @spec gravity(t()) :: Decimal.t()
  def gravity(planet), do: @gravity |> Keyword.fetch!(planet) |> Decimal.new()
end
