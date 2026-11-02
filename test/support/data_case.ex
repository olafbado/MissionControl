defmodule FuelCalculator.DataCase do
  @moduledoc """
  This module defines the setup for tests of the application's data layer:
  schemas, changesets and contexts.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import FuelCalculator.DataCase
    end
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert %{mass: ["can't be blank"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
