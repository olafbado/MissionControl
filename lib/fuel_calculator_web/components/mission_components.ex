defmodule FuelCalculatorWeb.MissionComponents do
  @moduledoc """
  Components for building a mission and presenting its fuel requirements.
  """
  use FuelCalculatorWeb, :html

  @action_options [{"Launch", :launch}, {"Land", :land}]
  @planet_options [{"Earth", :earth}, {"Moon", :moon}, {"Mars", :mars}]

  @doc """
  Renders a single flight path step inside the mission form.
  """
  attr :step, :map, required: true, doc: "the step params with action and planet keys"
  attr :index, :integer, required: true, doc: "the zero-based position in the flight path"

  def step_row(assigns) do
    assigns = assign(assigns, :number, assigns.index + 1)

    ~H"""
    <li
      id={"step-#{@index}"}
      class="flex items-start gap-3 rounded-box border border-base-300 bg-base-100 p-3 transition-colors hover:border-base-content/20"
    >
      <span class="badge badge-neutral mt-2 tabular-nums" aria-hidden="true">{@number}</span>
      <div class="grid flex-1 grid-cols-1 gap-x-3 sm:grid-cols-2">
        <.input
          type="select"
          id={"mission_steps_#{@index}_action"}
          name={"mission[steps][#{@index}][action]"}
          value={@step["action"]}
          prompt="Choose action"
          options={action_options()}
          aria-label={"Step #{@number} action"}
        />
        <.input
          type="select"
          id={"mission_steps_#{@index}_planet"}
          name={"mission[steps][#{@index}][planet]"}
          value={@step["planet"]}
          prompt="Choose planet"
          options={planet_options()}
          aria-label={"Step #{@number} planet"}
        />
      </div>
      <button
        type="button"
        id={"remove-step-#{@index}"}
        class="btn btn-ghost btn-square btn-sm mt-1"
        aria-label={"Remove step #{@number}"}
      >
        <.icon name="hero-trash" class="size-4" />
      </button>
    </li>
    """
  end

  @doc """
  Renders the total fuel required, or a hint while it is unknown.
  """
  attr :fuel, Decimal, default: nil, doc: "the total fuel in kg, nil while unknown"

  def fuel_summary(assigns) do
    ~H"""
    <section id="fuel-summary" aria-live="polite" class="rounded-box bg-base-200 p-6">
      <h2 class="text-sm font-medium text-base-content/70">Total fuel required</h2>
      <%= if @fuel do %>
        <p id="total-fuel" class="mt-1 text-4xl font-semibold tabular-nums">
          {@fuel} <span class="text-lg font-normal text-base-content/70">kg</span>
        </p>
      <% else %>
        <p id="fuel-hint" class="mt-1 text-base-content/70">
          Enter the spacecraft mass and choose an action and planet for every step.
        </p>
      <% end %>
    </section>
    """
  end

  defp action_options, do: @action_options
  defp planet_options, do: @planet_options
end
