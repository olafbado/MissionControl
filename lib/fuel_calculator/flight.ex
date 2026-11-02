defmodule FuelCalculator.Flight do
  @moduledoc """
  The Flight context.
  """
  alias FuelCalculator.Flight.Action
  alias FuelCalculator.Flight.Fuel
  alias FuelCalculator.Flight.Mission
  alias FuelCalculator.Flight.Planet
  alias FuelCalculator.Flight.Step

  # The example missions from the challenge: {id, name, mass in kg, flight path}.
  @example_missions [
    {"apollo_11", "Apollo 11", 28_801,
     [launch: :earth, land: :moon, launch: :moon, land: :earth]},
    {"mars_mission", "Mars mission", 14_606,
     [launch: :earth, land: :mars, launch: :mars, land: :earth]},
    {"passenger_ship", "Passenger ship", 75_432,
     [launch: :earth, land: :moon, launch: :moon, land: :mars, launch: :mars, land: :earth]}
  ]

  @spec change_mission(Mission.t(), map()) :: Ecto.Changeset.t()
  def change_mission(%Mission{} = mission, attrs \\ %{}) do
    Mission.changeset(mission, attrs)
  end

  @spec list_example_missions() :: [{String.t(), String.t()}]
  def list_example_missions do
    Enum.map(@example_missions, fn {id, name, _mass, _path} -> {id, name} end)
  end

  @spec get_example_mission(String.t()) :: Mission.t()
  def get_example_mission(id) do
    {_id, _name, mass, path} = List.keyfind!(@example_missions, id, 0)
    steps = Enum.map(path, fn {action, planet} -> %Step{action: action, planet: planet} end)

    %Mission{mass: Decimal.new(mass), steps: steps}
  end

  @spec calculate_fuel(Mission.t()) :: Decimal.t()
  def calculate_fuel(%Mission{mass: mass, steps: steps}) do
    Fuel.for_path(mass, Enum.map(steps, &{&1.action, &1.planet}))
  end

  @spec actions() :: [Action.t()]
  defdelegate actions, to: Action, as: :all

  @spec planets() :: [Planet.t()]
  defdelegate planets, to: Planet, as: :all

  @spec gravity(Planet.t()) :: Decimal.t()
  defdelegate gravity(planet), to: Planet
end
