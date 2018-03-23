defmodule Estimator.Issue.SelectedIssue do
  @moduledoc """
  Provides schema and changesets for selected issues
  """
  use Estimator.Schema
  use Timex.Ecto.Timestamps

  schema "selected_issues" do
    field :key, :string
    field :board_id, :integer
    field :link, :string
    field :selected, :boolean, default: false
    field :summary, :string
    field :description, :string
    field :estimation, :string
    field :raw, :map

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :board_id, :link, :selected, :summary, :description, :raw])
    |> validate_required([:key, :board_id, :link, :selected, :summary, :description, :raw])
    |> unique_constraint(:key)
  end

  def changeset_set_estimation(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :estimation])
    |> validate_required([:key, :estimation])
  end

  @doc """
  Fetch raw data, like returned from the Jira API
  """
  def fetch(issue, key) do
    {:ok, issue.raw[key]}
  end
end
