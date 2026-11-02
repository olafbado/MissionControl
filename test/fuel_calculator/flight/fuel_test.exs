defmodule FuelCalculator.Flight.FuelTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.Flight.Fuel

  @apollo_11 [launch: :earth, land: :moon, launch: :moon, land: :earth]
  @mars_mission [launch: :earth, land: :mars, launch: :mars, land: :earth]
  @passenger_ship [
    launch: :earth,
    land: :moon,
    launch: :moon,
    land: :mars,
    launch: :mars,
    land: :earth
  ]
  @grand_tour [
    launch: :earth,
    land: :moon,
    launch: :moon,
    land: :mars,
    launch: :mars,
    land: :moon,
    launch: :moon,
    land: :earth
  ]

  describe "for_step/3" do
    test "works for launching and landing on every planet" do
      assert kg(Fuel.for_step(Decimal.new(28_801), :launch, :earth)) == 19_772
      assert kg(Fuel.for_step(Decimal.new(42_248), :launch, :moon)) == 3001
      assert kg(Fuel.for_step(Decimal.new(45_249), :land, :moon)) == 2462
      assert kg(Fuel.for_step(Decimal.new(10_000), :launch, :mars)) == 1729
      assert kg(Fuel.for_step(Decimal.new(10_000), :land, :mars)) == 1284
    end

    test "gives exact results for very heavy ships" do
      assert kg(Fuel.for_step(Decimal.new(123_456_789_012_345_678), :land, :earth)) ==
               59_071_962_323_603_123
    end

    test "needs no fuel for a very light ship" do
      assert kg(Fuel.for_step(Decimal.new(100), :land, :earth)) == 0
      assert kg(Fuel.for_step(Decimal.new(1), :launch, :moon)) == 0
    end
  end

  describe "for_path/2" do
    test "calculates the fuel for a whole flight path" do
      assert kg(Fuel.for_path(Decimal.new(28_801), @apollo_11)) == 51_898
      assert kg(Fuel.for_path(Decimal.new(14_606), @mars_mission)) == 33_388
      assert kg(Fuel.for_path(Decimal.new(75_432), @passenger_ship)) == 212_161
      assert kg(Fuel.for_path(Decimal.new(123_456), @grand_tour)) == 411_392
    end

    test "works with a mass that has decimals" do
      assert kg(Fuel.for_path(Decimal.new("28801.5"), @apollo_11)) == 51_900
    end

    test "needs no fuel when there are no steps" do
      assert kg(Fuel.for_path(Decimal.new(28_801), [])) == 0
    end
  end

  defp kg(fuel), do: Decimal.to_integer(fuel)
end
