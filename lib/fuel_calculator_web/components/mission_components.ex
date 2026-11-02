defmodule FuelCalculatorWeb.MissionComponents do
  @moduledoc """
  Components for building a mission and presenting its fuel requirements.
  """
  use FuelCalculatorWeb, :html

  alias FuelCalculator.Flight
  alias Phoenix.HTML.Form

  @doc """
  Renders a numbered section of the mission form.
  """
  attr :number, :string, required: true
  attr :title, :string, required: true

  slot :actions, doc: "optional controls shown at the end of the heading"
  slot :inner_block, required: true

  def form_section(assigns) do
    ~H"""
    <section class="space-y-4">
      <div class="flex items-center justify-between gap-4">
        <h2 class="flex items-baseline gap-4 text-xl font-semibold">
          <span class="text-primary tabular-nums">{@number}</span> {@title}
        </h2>
        {render_slot(@actions)}
      </div>
      <div class="sm:pl-12">{render_slot(@inner_block)}</div>
    </section>
    """
  end

  @doc """
  Renders the equipment mass input with a kg suffix and its errors.
  """
  attr :field, Phoenix.HTML.FormField, required: true

  def mass_input(%{field: field} = assigns) do
    errors = if used_input?(field), do: field.errors, else: []
    assigns = assign(assigns, :errors, Enum.map(errors, &translate_error/1))

    ~H"""
    <div class="fieldset">
      <label for={@field.id} class="label text-sm text-base-content">Equipment mass</label>
      <div class={["input input-lg w-full", @errors != [] && "input-error"]}>
        <input
          type="number"
          id={@field.id}
          name={@field.name}
          value={Form.normalize_value("number", @field.value)}
          min="0"
          step="any"
          inputmode="decimal"
          placeholder="e.g. 28801"
          class="grow"
        />
        <span class="label">kg</span>
      </div>
      <p class="label">Dry mass, excluding fuel.</p>
      <p :for={msg <- @errors} class="flex items-center gap-2 text-sm text-error">
        <.icon name="hero-exclamation-circle" class="size-5" /> {msg}
      </p>
    </div>
    """
  end

  @doc """
  Renders a single flight path step inside the mission form.

  Includes the hidden sort input and the remove button that drive
  `Ecto.Changeset.cast_embed/3`'s `:sort_param` and `:drop_param`.
  """
  attr :step, Phoenix.HTML.Form, required: true, doc: "the nested form of a single step"
  attr :path_error, :any, default: nil, doc: "the broken flight path rule of this step, if any"

  def step_row(assigns) do
    assigns =
      assigns
      |> assign(:number, assigns.step.index + 1)
      |> assign(:gravity, step_gravity(assigns.step))
      |> assign(:path_error, path_error(assigns.path_error))

    ~H"""
    <li
      id={"step-#{@step.index}"}
      class="py-3"
      phx-mounted={
        JS.transition(
          {"ease-out duration-300", "opacity-0 -translate-y-1", "opacity-100 translate-y-0"}
        )
      }
    >
      <input type="hidden" name="mission[steps_sort][]" value={@step.index} />
      <div class="flex items-start gap-3">
        <span
          class="mt-1 flex h-10 w-6 shrink-0 items-center justify-center text-base-content/70 tabular-nums"
          aria-hidden="true"
        >
          {@number}
        </span>
        <div class="grid flex-1 grid-cols-2 gap-3 sm:grid-cols-[1fr_1fr_6.5rem] *:mb-0">
          <.input
            field={@step[:action]}
            type="select"
            prompt="Action"
            options={action_options()}
            class={select_class(@path_error, :action)}
            aria-label={"Step #{@number} action"}
          />
          <.input
            field={@step[:planet]}
            type="select"
            prompt="Planet"
            options={planet_options()}
            class={select_class(@path_error, :planet)}
            aria-label={"Step #{@number} planet"}
          />
          <div class="mt-1 hidden h-10 flex-col justify-center leading-tight sm:flex">
            <span class="text-xs text-base-content/60">Gravity</span>
            <span class="text-sm tabular-nums">{gravity_label(@gravity)}</span>
          </div>
        </div>
        <button
          type="button"
          id={"remove-step-#{@step.index}"}
          name="mission[steps_drop][]"
          value={@step.index}
          phx-click={JS.dispatch("change")}
          class="btn btn-square btn-ghost mt-1 border-base-300 hover:border-error hover:text-error"
          aria-label={"Remove step #{@number}"}
        >
          <.icon name="hero-x-mark" class="size-5" />
        </button>
      </div>
      <p :if={@path_error} class="mt-2 flex items-center gap-2 pl-9 text-sm text-error">
        <.icon name="hero-exclamation-triangle" class="size-5" /> {@path_error.message}
      </p>
    </li>
    """
  end

  @doc """
  Renders the fuel summary: the total, the mission figures and the route.
  """
  attr :fuel, Decimal, default: nil, doc: "the total fuel in kg, nil while unknown"
  attr :mass, Decimal, default: nil, doc: "the equipment mass in kg, nil while invalid"
  attr :step_count, :integer, required: true
  attr :path_errors, :integer, default: 0, doc: "the number of broken flight path rules"
  attr :route, :list, required: true, doc: "the planets visited, in order"

  def fuel_summary(assigns) do
    ~H"""
    <section
      id="fuel-summary"
      aria-live="polite"
      class="rounded-box border border-base-300 bg-base-200 p-6 sm:p-8"
    >
      <p class="flex items-center gap-2 text-sm text-base-content/70">
        <span class="relative flex size-2.5">
          <span class="absolute inline-flex size-full animate-ping rounded-full bg-primary opacity-60"></span>
          <span class="relative inline-flex size-2.5 rounded-full bg-primary"></span>
        </span>
        Updated live
      </p>

      <h2 class="mt-6 text-lg font-medium">Total fuel required</h2>
      <%= if @fuel do %>
        <p id="total-fuel" class="mt-1 text-6xl font-bold tracking-tight tabular-nums">
          {@fuel}<span class="ml-2 text-3xl font-semibold text-base-content/50">kg</span>
        </p>
      <% else %>
        <p id="fuel-hint" class="mt-2 text-base-content/60">{fuel_hint(@path_errors)}</p>
      <% end %>

      <dl class="mt-6 divide-y divide-base-300 border-y border-base-300 text-sm">
        <.stat id="equipment-mass" label="Equipment mass">{kg(@mass)}</.stat>
        <.stat id="fuel-mass" label="Fuel mass">{kg(@fuel)}</.stat>
        <.stat id="total-mass" label="Initial total mass">
          {kg(total_mass(@mass, @fuel))}
        </.stat>
        <.stat id="step-count" label="Flight steps">{@step_count}</.stat>
      </dl>
      <p class="mt-4 text-xs text-base-content/60">
        Includes fuel needed to carry fuel through every step.
      </p>

      <.route_map route={@route} />
    </section>
    """
  end

  @doc """
  Renders the visited planets in order, connected by dashed arrows.
  """
  attr :route, :list, required: true, doc: "the planets visited, in order"

  def route_map(%{route: []} = assigns) do
    ~H"""
    <p id="route" class="mt-8 text-center text-sm text-base-content/60">
      Choose planets to see the route.
    </p>
    """
  end

  def route_map(assigns) do
    ~H"""
    <ol id="route" class="mt-8 flex overflow-x-auto pb-2">
      <li
        :for={{planet, index} <- Enum.with_index(@route)}
        class={["flex items-start", index > 0 && "flex-1"]}
      >
        <span
          :if={index > 0}
          class="flex h-12 min-w-8 flex-1 items-center text-base-content/40"
          aria-hidden="true"
        >
          <span class="flex-1 border-t border-dashed border-current"></span>
          <.icon name="hero-chevron-right-micro" class="size-4" />
        </span>
        <span class="flex flex-col items-center gap-2">
          <span class="flex h-12 items-center">
            <span class={["rounded-full shadow-lg", planet_class(planet)]}></span>
          </span>
          <span class="text-sm font-medium">{Phoenix.Naming.humanize(planet)}</span>
        </span>
      </li>
    </ol>
    """
  end

  attr :id, :string, required: true
  attr :label, :string, required: true
  slot :inner_block, required: true

  defp stat(assigns) do
    ~H"""
    <div id={@id} class="flex items-center justify-between py-3">
      <dt class="text-base-content/70">{@label}</dt>
      <dd class="font-medium tabular-nums">{render_slot(@inner_block)}</dd>
    </div>
    """
  end

  defp options(values), do: Enum.map(values, &{Phoenix.Naming.humanize(&1), &1})

  defp action_options, do: options(Flight.actions())
  defp planet_options, do: options(Flight.planets())

  defp step_gravity(%Form{source: step_changeset}) do
    case Ecto.Changeset.get_field(step_changeset, :planet) do
      nil -> nil
      planet -> Flight.gravity(planet)
    end
  end

  # Shown on the row even before the user touches its selects, because the
  # error can be caused by editing another step.
  defp path_error(nil), do: nil

  defp path_error({_message, opts} = error),
    do: %{field: opts[:field], message: translate_error(error)}

  defp select_class(%{field: field}, field), do: "w-full select select-error"
  defp select_class(_path_error, _field), do: "w-full select"

  defp gravity_label(nil), do: "-"
  defp gravity_label(gravity), do: "#{gravity} m/s²"

  defp fuel_hint(0),
    do: "Enter the equipment mass and choose an action and planet for every step."

  defp fuel_hint(path_errors) do
    ngettext(
      "Resolve 1 flight path error to calculate.",
      "Resolve %{count} flight path errors to calculate.",
      path_errors
    )
  end

  defp kg(nil), do: "-"
  defp kg(value), do: "#{value} kg"

  defp total_mass(%Decimal{} = mass, %Decimal{} = fuel), do: Decimal.add(mass, fuel)
  defp total_mass(_mass, _fuel), do: nil

  defp planet_class(:earth),
    do: "size-12 bg-radial-[at_30%_30%] from-sky-300 via-blue-600 to-blue-950"

  defp planet_class(:moon),
    do: "size-7 bg-radial-[at_30%_30%] from-gray-100 via-gray-400 to-gray-700"

  defp planet_class(:mars),
    do: "size-9 bg-radial-[at_30%_30%] from-orange-300 via-orange-600 to-red-900"
end
