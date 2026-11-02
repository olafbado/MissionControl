defmodule FuelCalculatorWeb.MissionLive do
  @moduledoc """
  Mission planner page
  """
  use FuelCalculatorWeb, :live_view

  import FuelCalculatorWeb.MissionComponents

  alias FuelCalculator.Flight
  alias FuelCalculator.Flight.Mission
  alias FuelCalculator.Flight.Step

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:example_missions, Flight.list_example_missions())
    |> assign(:selected_example_mission, nil)
    |> reset_mission()
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("validate", %{"mission" => params}, socket) do
    mission_changeset = Flight.change_mission(socket.assigns.mission, params)

    socket
    |> assign(:selected_example_mission, nil)
    |> assign_form(mission_changeset, action: :validate)
    |> then(&{:noreply, &1})
  end

  def handle_event("toggle_example_mission", %{"id" => id}, socket) do
    if socket.assigns.selected_example_mission == id do
      socket
      |> reset_mission()
      |> then(&{:noreply, &1})
    else
      socket
      |> assign(:selected_example_mission, id)
      |> assign_mission(Flight.get_example_mission(id))
      |> then(&{:noreply, &1})
    end
  end

  def handle_event("reset", _params, socket) do
    socket
    |> reset_mission()
    |> then(&{:noreply, &1})
  end

  defp reset_mission(socket) do
    socket
    |> assign(:selected_example_mission, nil)
    |> assign_mission(%Mission{steps: [%Step{}]})
  end

  defp assign_mission(socket, mission) do
    socket
    |> assign(:mission, mission)
    |> assign_form(Flight.change_mission(mission))
  end

  defp assign_form(socket, mission_changeset, opts \\ []) do
    steps = Ecto.Changeset.get_field(mission_changeset, :steps)

    socket
    |> assign(:form, to_form(mission_changeset, opts))
    |> assign_summary(mission_changeset)
    |> assign(:path_errors, path_errors(mission_changeset))
    |> assign(:step_count, length(steps))
    |> assign(:visited_planets, visited_planets(steps))
  end

  defp assign_summary(socket, mission_changeset) do
    if mission_changeset.valid? do
      mission = Ecto.Changeset.apply_changes(mission_changeset)
      fuel = Flight.calculate_fuel(mission)

      assign(socket, mass: mission.mass, fuel: fuel)
    else
      assign(socket, mass: nil, fuel: nil)
    end
  end

  # Broken flight path rules by the index of the offending step.
  defp path_errors(mission_changeset) do
    mission_changeset.errors
    |> Keyword.get_values(:flight_path)
    |> Map.new(fn {_message, opts} = error -> {opts[:step], error} end)
  end

  defp visited_planets(steps) do
    steps
    |> Enum.map(& &1.planet)
    |> Enum.reject(&is_nil/1)
    |> Enum.dedup()
  end
end
