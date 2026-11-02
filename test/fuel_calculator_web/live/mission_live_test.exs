defmodule FuelCalculatorWeb.MissionLiveTest do
  use FuelCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    %{view: view}
  end

  test "renders the mass input, a single empty step and the fuel summary", %{view: view} do
    assert has_element?(view, "#mission-form #mission_mass")
    assert has_element?(view, "#step-0 #mission_steps_0_action")
    assert has_element?(view, "#step-0 #mission_steps_0_planet")
    refute has_element?(view, "#step-1")
    assert has_element?(view, "#fuel-hint")
  end

  test "loads an example mission", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()

    assert has_element?(view, "#example-mission-apollo_11[aria-pressed=true]")
    assert has_element?(view, "#mission_mass[value='28801']")
    assert has_element?(view, "#step-3 #mission_steps_3_planet option[value=earth][selected]")
    assert has_element?(view, "#route li:nth-child(1)", "Earth")
    assert has_element?(view, "#route li:nth-child(2)", "Moon")
    assert has_element?(view, "#route li:nth-child(3)", "Earth")
    assert has_element?(view, "#total-fuel", "51898")
    assert has_element?(view, "#equipment-mass", "28801 kg")
    assert has_element?(view, "#fuel-mass", "51898 kg")
    assert has_element?(view, "#total-mass", "80699 kg")
    assert has_element?(view, "#step-count", "4")
  end

  test "editing the mass clears the selection and recalculates", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()

    view
    |> form("#mission-form", mission: %{mass: "30000"})
    |> render_change()

    assert has_element?(view, "#example-mission-apollo_11[aria-pressed=false]")
    assert has_element?(view, "#total-fuel", "54109")
    assert has_element?(view, "#total-mass", "84109 kg")
  end

  test "clicking the active example mission again clears the form", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()
    view |> element("#example-mission-apollo_11") |> render_click()

    assert_blank_mission(view)
  end

  test "resets the form", %{view: view} do
    view |> element("#example-mission-passenger_ship") |> render_click()
    view |> element("#reset-mission") |> render_click()

    assert_blank_mission(view)
  end

  test "an invalid mass shows an error and hides the fuel", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()

    view
    |> form("#mission-form", mission: %{mass: "-5"})
    |> render_change()

    assert has_element?(view, "#mission-form p", "must be greater than 0")
    assert has_element?(view, "#fuel-hint")
    refute has_element?(view, "#total-fuel")
    assert has_element?(view, "#equipment-mass", "-")
    assert has_element?(view, "#total-mass", "-")
  end

  test "shows an error for a step missing its planet", %{view: view} do
    view
    |> form("#mission-form", mission: %{mass: "100", steps: %{"0" => %{action: "launch"}}})
    |> render_change()

    assert has_element?(view, "#step-0 p", "can't be blank")
  end

  test "shows a flight path error on its step and hides the fuel", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()

    # Launch from Mars right after landing on the Moon.
    view
    |> form("#mission-form", mission: %{steps: %{"2" => %{planet: "mars"}}})
    |> render_change()

    assert has_element?(view, "#step-2", "Launch from Moon, where you last landed.")
    assert has_element?(view, "#mission_steps_2_planet.select-error")
    assert has_element?(view, "#fuel-hint", "Resolve 1 flight path error to calculate.")
    refute has_element?(view, "#total-fuel")
  end

  test "shows the gravity of the chosen planet", %{view: view} do
    view
    |> form("#mission-form", mission: %{steps: %{"0" => %{planet: "moon"}}})
    |> render_change()

    assert has_element?(view, "#step-0", "1.62 m/s²")
  end

  test "recalculates when the flight path is edited", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()

    # Turn Apollo 11 into the Mars mission by hand.
    view
    |> form("#mission-form",
      mission: %{
        mass: "14606",
        steps: %{"1" => %{planet: "mars"}, "2" => %{planet: "mars"}}
      }
    )
    |> render_change()

    assert has_element?(view, "#total-fuel", "33388")
  end

  test "hides the total while a new step is incomplete and includes it once complete",
       %{view: view} do
    view |> element("#example-mission-mars_mission") |> render_click()

    # What the add step button sends.
    view
    |> form("#mission-form")
    |> render_change(%{mission: %{steps_sort: ["0", "1", "2", "3", "new"]}})

    assert has_element?(view, "#step-4")
    assert has_element?(view, "#fuel-hint")
    refute has_element?(view, "#total-fuel")

    view
    |> form("#mission-form", mission: %{steps: %{"4" => %{action: "launch", planet: "earth"}}})
    |> render_change()

    assert has_element?(view, "#total-fuel", "66795")
  end

  test "recalculates when a step is removed", %{view: view} do
    view |> element("#example-mission-apollo_11") |> render_click()

    # What the remove button of the last step sends.
    view
    |> form("#mission-form")
    |> render_change(%{mission: %{steps_drop: ["3"]}})

    assert has_element?(view, "#total-fuel", "26011")
    assert has_element?(view, "#step-count", "3")
  end

  test "removing every step shows the empty message and needs no fuel", %{view: view} do
    view
    |> form("#mission-form", mission: %{mass: "28801"})
    |> render_change(%{mission: %{steps_drop: ["0"]}})

    assert has_element?(view, "#flight-path-empty")
    assert has_element?(view, "#fuel-mass", "0 kg")
    assert has_element?(view, "#step-count", "0")
  end

  defp assert_blank_mission(view) do
    refute has_element?(view, "[id^=example-mission-][aria-pressed=true]")
    refute has_element?(view, "#mission_mass[value]")
    assert has_element?(view, "#step-0")
    refute has_element?(view, "#step-1")
    refute has_element?(view, "#mission_steps_0_planet option[selected]")
  end
end
