defmodule Estimator.Issue.SelectedIssueTest do
  use Estimator.DataCase, async: true

  alias Estimator.Issue.SelectedIssue
  import Estimator.Factory, only: [build: 1, build: 2]

  describe ".changeset" do
    test "validates required information" do
      expected = %{
        board_id: ["can't be blank"],
        description: ["can't be blank"],
        key: ["can't be blank"],
        link: ["can't be blank"],
        raw: ["can't be blank"],
        summary: ["can't be blank"],
      }
      changeset = SelectedIssue.changeset(%SelectedIssue{})
      assert expected == errors_on(changeset)
    end

    test "validates with example fixture" do
      changeset = SelectedIssue.changeset(build(:issue))
      assert %{} == errors_on(changeset)
    end

    test "expects estimation to be set" do
      changeset = build(:issue)
        |> SelectedIssue.changeset_set_estimation(%{estimation: nil})
      assert %{estimation: ["can't be blank"]} == errors_on(changeset)

      changeset = build(:issue)
        |> SelectedIssue.changeset_set_estimation(%{estimation: "M"})
      assert %{} == errors_on(changeset)
    end
  end

  describe ".raw" do
    test "information is accessible" do
      issue = build(:issue, raw: %{"key" => "value"})
      assert "value" == issue["key"]
    end

    test "returns nil if not defined" do
      assert nil == build(:issue)["something"]
    end
  end
end
