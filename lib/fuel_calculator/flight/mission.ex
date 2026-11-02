defmodule FuelCalculator.Flight.Mission do
  @moduledoc """
  A mission: the spacecraft mass and the flight path it follows.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias FuelCalculator.Flight.Step

  @type t :: %__MODULE__{
          mass: Decimal.t() | nil,
          steps: [Step.t()]
        }

  @primary_key false
  embedded_schema do
    field :mass, :decimal
    embeds_many :steps, Step, on_replace: :delete
  end

  @doc """
  Validates the mission.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(mission, attrs) do
    mission
    |> cast(attrs, [:mass])
    |> validate_required([:mass])
    |> validate_number(:mass, greater_than: 0)
    |> cast_embed(:steps,
      with: &Step.changeset/2,
      sort_param: :steps_sort,
      drop_param: :steps_drop
    )
    |> validate_flight_path()
  end

  # Compares every step with the previous one. Rules:
  #
  #   * launch and land must alternate
  #   * a launch must be from the planet of the previous landing
  #
  defp validate_flight_path(changeset) do
    changeset
    |> get_field(:steps)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index(1)
    |> Enum.reduce(changeset, fn {[previous, step], index}, changeset ->
      case order_error({previous.action, previous.planet}, {step.action, step.planet}) do
        nil ->
          changeset

        {field, message, keys} ->
          add_error(changeset, :flight_path, message, [step: index, field: field] ++ keys)
      end
    end)
  end

  defp order_error({:launch, _planet}, {:launch, _next_planet}) do
    {:action, "Expected a landing after a launch.", []}
  end

  defp order_error({:land, _planet}, {:land, _next_planet}) do
    {:action, "Expected a launch after a landing.", []}
  end

  defp order_error({:land, landed_on}, {:launch, launched_from})
       when landed_on != nil and launched_from != nil and landed_on != launched_from do
    planet = landed_on |> Atom.to_string() |> String.capitalize()
    {:planet, "Launch from %{planet}, where you last landed.", planet: planet}
  end

  defp order_error(_previous, _current), do: nil
end
