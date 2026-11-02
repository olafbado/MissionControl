defmodule FuelCalculator.FlightTest do
  use FuelCalculator.DataCase, async: true

  alias FuelCalculator.Flight
  alias FuelCalculator.Flight.Mission
  alias FuelCalculator.Flight.Step

  @launch_earth %{"action" => "launch", "planet" => "earth"}
  @land_moon %{"action" => "land", "planet" => "moon"}

  describe "change_mission/2" do
    test "is valid with a positive mass and complete steps" do
      changeset =
        Flight.change_mission(%Mission{}, %{
          "mass" => "28801.5",
          "steps" => %{"0" => @launch_earth, "1" => @land_moon}
        })

      assert changeset.valid?

      assert %Mission{mass: mass, steps: steps} = Ecto.Changeset.apply_changes(changeset)
      assert Decimal.equal?(mass, "28801.5")
      assert Enum.map(steps, &{&1.action, &1.planet}) == [launch: :earth, land: :moon]
    end

    test "requires a mass" do
      assert %{mass: ["can't be blank"]} = errors_on(Flight.change_mission(%Mission{}))
    end

    test "requires a mass greater than zero" do
      Enum.each(["0", "-1"], fn mass ->
        changeset = Flight.change_mission(%Mission{}, %{"mass" => mass})
        assert %{mass: ["must be greater than 0"]} = errors_on(changeset)
      end)
    end

    test "rejects a non-numeric mass" do
      changeset = Flight.change_mission(%Mission{}, %{"mass" => "heavy"})
      assert %{mass: ["is invalid"]} = errors_on(changeset)
    end

    test "requires an action and a planet for every step" do
      changeset = Flight.change_mission(%Mission{}, %{"mass" => "100", "steps" => %{"0" => %{}}})

      assert %{steps: [%{action: ["can't be blank"], planet: ["can't be blank"]}]} =
               errors_on(changeset)
    end

    test "rejects unsupported actions and planets" do
      step = %{"action" => "orbit", "planet" => "pluto"}

      changeset = Flight.change_mission(%Mission{}, %{"mass" => "100", "steps" => %{"0" => step}})

      assert %{steps: [%{action: ["is invalid"], planet: ["is invalid"]}]} = errors_on(changeset)
    end

    test "the add step button appends an empty step" do
      # Each row sends its index in steps_sort and the add step button appends "new".
      changeset =
        Flight.change_mission(%Mission{}, %{
          "steps" => %{"0" => @launch_earth},
          "steps_sort" => ["0", "new"]
        })

      assert [%Step{action: :launch}, %Step{action: nil}] =
               Ecto.Changeset.get_field(changeset, :steps)
    end

    test "the remove step button drops its step" do
      # The remove step button sends the index of its row in steps_drop.
      changeset =
        Flight.change_mission(%Mission{}, %{
          "steps" => %{"0" => @launch_earth, "1" => @land_moon},
          "steps_sort" => ["0", "1"],
          "steps_drop" => ["0"]
        })

      assert [%Step{action: :land, planet: :moon}] = Ecto.Changeset.get_field(changeset, :steps)
    end
  end

  describe "get_example_mission/1" do
    test "builds a valid example mission for every example mission" do
      Enum.each(Flight.list_example_missions(), fn {id, _name} ->
        changeset = Flight.change_mission(Flight.get_example_mission(id))
        assert changeset.valid?
      end)
    end
  end

  describe "calculate_fuel/1" do
    test "calculates the fuel of every example mission" do
      expected_fuel = %{
        "apollo_11" => 51_898,
        "mars_mission" => 33_388,
        "passenger_ship" => 212_161
      }

      Enum.each(expected_fuel, fn {id, fuel} ->
        mission = Flight.get_example_mission(id)
        assert Decimal.to_integer(Flight.calculate_fuel(mission)) == fuel
      end)
    end
  end

  describe "gravity/1" do
    test "returns the surface gravity of every planet" do
      assert Flight.planets() == [:earth, :moon, :mars]
      assert Decimal.equal?(Flight.gravity(:earth), "9.807")
      assert Decimal.equal?(Flight.gravity(:moon), "1.62")
      assert Decimal.equal?(Flight.gravity(:mars), "3.711")
    end
  end
end
