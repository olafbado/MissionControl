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
  Validates the mass and every flight path step.
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
  end
end
