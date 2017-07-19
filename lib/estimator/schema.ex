defmodule Estimator.Schema do
  @moduledoc """
  Ecto schema
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
    end
  end
end
