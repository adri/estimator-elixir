defmodule Estimator.Vote.Vote do
  use Estimator.Schema
  use Timex.Ecto.Timestamps

  schema "votes" do
    field :topic, :string
    field :issue_key, :string
    field :user_id, :string
    field :vote, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:topic, :issue_key, :user_id, :vote])
    |> validate_required([:topic, :issue_key, :user_id, :vote])
  end
end
