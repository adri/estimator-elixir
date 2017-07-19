defmodule Estimator.Factory do
  @moduledoc """
  Build and insert test data.

  ## Examples

      Factory.build(:user)
      # => %Picape.User{name: "John Smith"}

      Factory.build(:user, name: "Jane Smith")
      # => %Picape.User{name: "Jane Smith"}

      Factory.insert!(:user, name: "Jane Smith")
      # => %Picape.User{name: "Jane Smith"}
  """

  alias Estimator.Repo

  def build(:issue) do
    %Estimator.Issue.SelectedIssue{
        board_id: 1,
        description: "Issue description",
        key: "KEY-001",
        link: "http://example.atlassian.net/browse/KEY-001",
        raw: %{example: "structure"},
        summary: "Longer issue description",
    }
  end

  def build(factory_name, attributes) do
    factory_name
    |> build()
    |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name
    |> build(attributes)
    |> Repo.insert!
  end
end
