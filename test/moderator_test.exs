defmodule Estimator.ModeratorTest do
  use ExUnit.Case, async: true

  alias Estimator.Moderator

  setup do
    {:ok, subject} = Moderator.start_link(name: {:global, __MODULE__})
    {:ok, subject: subject}
  end

  test ".set moderator for topic", %{subject: subject} do
    Moderator.set_for_topic(1, 'topic', subject)
  end

  test ".get moderator for topic", %{subject: subject} do
    Moderator.set_for_topic(1, 'topic', subject)

    assert Moderator.get_for_topic('topic', subject) === 1
  end

  test ".determine for topic", %{subject: subject} do
    Moderator.set_for_topic(2, 'topic', subject)

    assert Moderator.determine_moderator([1, 2, 3], 'topic', subject) === 2
  end
end
