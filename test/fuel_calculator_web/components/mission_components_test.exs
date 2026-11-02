defmodule FuelCalculatorWeb.MissionComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias FuelCalculatorWeb.MissionComponents

  describe "fuel_summary/1" do
    test "shows the total fuel" do
      html = render_component(&MissionComponents.fuel_summary/1, fuel: Decimal.new(212_161))

      assert html =~ "212161"
      refute html =~ "fuel-hint"
    end

    test "shows a hint while the fuel is unknown" do
      html = render_component(&MissionComponents.fuel_summary/1, fuel: nil)

      assert html =~ "fuel-hint"
      refute html =~ "total-fuel"
    end
  end
end
