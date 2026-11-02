defmodule FuelCalculator.Flight.Step do
  @moduledoc """
  A single flight path step: launching from or landing on a planet.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias FuelCalculator.Flight.Action
  alias FuelCalculator.Flight.Planet

  @type t :: %__MODULE__{
          action: Action.t() | nil,
          planet: Planet.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :action, Ecto.Enum, values: Action.all()
    field :planet, Ecto.Enum, values: Planet.all()
  end

  @doc "Validates that a supported action and planet are both chosen."
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:action, :planet])
    |> validate_required([:action, :planet])
  end
end
