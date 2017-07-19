defmodule Estimator.Vote.Vote do
  @moduledoc """
  Represents a vote by a user for a specific issue
  """
  use Estimator.Schema
  use Timex.Ecto.Timestamps

  schema "votes" do
    field :topic, :string
    field :issue_key, :string
    field :user_id, :string
    field :vote, :string

    timestamps()
  end

  @type t :: %Estimator.Vote.Vote{
    id: vote_id | nil,
    topic: String.t | nil,
    issue_key: Estimator.Issue.issue_key | nil,
    user_id: String.t | nil,
    vote: String.t | nil,
  }

  @type vote_id :: integer

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:topic, :issue_key, :user_id, :vote])
    |> validate_required([:topic, :issue_key, :user_id, :vote])
  end
end
