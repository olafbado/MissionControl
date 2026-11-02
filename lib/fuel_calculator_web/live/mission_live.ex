defmodule FuelCalculatorWeb.MissionLive do
  @moduledoc """
  Mission planner page: the spacecraft mass, the flight path steps and the
  fuel summary.
  """
  use FuelCalculatorWeb, :live_view

  import FuelCalculatorWeb.MissionComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       form: to_form(%{"mass" => ""}, as: :mission),
       steps: [%{"action" => nil, "planet" => nil}],
       fuel: nil
     )}
  end
end
