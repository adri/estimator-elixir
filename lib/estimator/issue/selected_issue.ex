defmodule Estimator.Issue.SelectedIssue do
  use Estimator.Schema

  schema "selected_issues" do
    field :key, :string
    field :link, :string
    field :selected, :boolean, default: false
    field :summary, :string
    field :description, :string
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
end
