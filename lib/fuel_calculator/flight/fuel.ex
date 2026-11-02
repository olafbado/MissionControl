defmodule FuelCalculator.Flight.Fuel do
  @moduledoc """
  Fuel calculations for single steps and whole flight paths.
  """
  alias FuelCalculator.Flight.Action
  alias FuelCalculator.Flight.Planet

  @type path :: [{Action.t(), Planet.t()}]

  @doc """
  Returns the total fuel for a flight path.

  The ship carries the fuel for all later steps, so the steps are calculated
  from the last to the first. For example, Apollo 11 with 28801 kg:

    * land on Earth carries 28801 kg and needs 13447 kg
    * launch from the Moon carries 28801 + 13447 = 42248 kg and needs 3001 kg
    * land on the Moon carries 42248 + 3001 = 45249 kg and needs 2462 kg
    * launch from Earth carries 45249 + 2462 = 47711 kg and needs 32988 kg

  In total: 13447 + 3001 + 2462 + 32988 = 51898 kg.
  """
  @spec for_path(Decimal.t(), path()) :: Decimal.t()
  def for_path(mass, path) do
    path
    |> Enum.reverse()
    |> Enum.reduce(Decimal.new(0), fn {action, planet}, total_fuel ->
      mass
      |> Decimal.add(total_fuel)
      |> for_step(action, planet)
      |> Decimal.add(total_fuel)
    end)
  end

  @doc """
  Returns the fuel for a single step, including the fuel needed to carry the
  fuel itself.

  For example, landing a 28801 kg ship on Earth:

    * the ship needs 9278 kg of fuel
    * those 9278 kg of fuel need 2960 kg more
    * those 2960 kg need 915 kg more
    * those 915 kg need 254 kg more
    * those 254 kg need 40 kg more
    * those 40 kg need no more

  In total: 9278 + 2960 + 915 + 254 + 40 = 13447 kg.
  """
  @spec for_step(Decimal.t(), Action.t(), Planet.t()) :: Decimal.t()
  def for_step(mass, action, planet) do
    fuel = formula(mass, action, planet)

    if Decimal.gt?(fuel, 0) do
      Decimal.add(fuel, for_step(fuel, action, planet))
    else
      Decimal.new(0)
    end
  end

  @spec formula(Decimal.t(), Action.t(), Planet.t()) :: Decimal.t()
  defp formula(mass, action, planet) do
    {multiplier, minus} = Action.formula(action)

    mass
    |> Decimal.mult(Planet.gravity(planet))
    |> Decimal.mult(multiplier)
    |> Decimal.sub(minus)
    |> Decimal.round(0, :floor)
  end
end
