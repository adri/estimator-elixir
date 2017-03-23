defmodule Estimator.Issue.SelectedIssue do
  use Estimator.Schema
  use Timex.Ecto.Timestamps

  schema "selected_issues" do
    field :key, :string
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
    |> cast(params, [:key, :link, :selected, :summary, :description, :raw])
    |> validate_required([:key, :link, :selected, :summary, :description, :raw])
  end

  def changeset_update_estimation(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :estimation])
    |> validate_required([:key, :estimation])
  end
end
