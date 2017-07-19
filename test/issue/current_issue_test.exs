defmodule Estimator.Issue.CurrentIssueTest do
  use ExUnit.Case, async: true

  alias Estimator.Issue.CurrentIssue

  setup do
    {:ok, subject} = CurrentIssue.start_link(name: {:global, __MODULE__})
    {:ok, subject: subject}
  end

  test "returns nil for a non existing topic", %{subject: subject}  do
    assert nil == CurrentIssue.get_for_topic('example', subject)
  end

  test "returns the current issue for an existing topic", %{subject: subject} do
    CurrentIssue.set_for_topic(123, 'example', subject)

    assert 123 == CurrentIssue.get_for_topic('example', subject)
  end
end