defmodule FuelCalculatorWeb.MissionComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias FuelCalculatorWeb.MissionComponents

  describe "fuel_summary/1" do
    test "shows the total fuel and the mission figures" do
      html =
        render_component(&MissionComponents.fuel_summary/1,
          fuel: Decimal.new(51_898),
          mass: Decimal.new(28_801),
          step_count: 4,
          route: [:earth, :moon, :earth]
        )

      route =
        html
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("#route li")
        |> Enum.map(&String.trim(LazyHTML.text(&1)))

      assert html =~ "51898"
      assert html =~ "80699 kg"
      assert route == ["Earth", "Moon", "Earth"]
      refute html =~ "fuel-hint"
    end

    test "shows a hint while the fuel is unknown" do
      html =
        render_component(&MissionComponents.fuel_summary/1,
          fuel: nil,
          mass: nil,
          step_count: 0,
          route: []
        )

      assert html =~ "fuel-hint"
      refute html =~ "total-fuel"
    end
  end
end
