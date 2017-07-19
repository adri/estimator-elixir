defmodule Estimator.Issue.CurrentIssue do
  @moduledoc """
  Stores the currently selected issue for a topic
  """
  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def get_for_topic(topic) do
    Agent.get(__MODULE__, &Map.get(&1, topic))
  end

  def set_for_topic(issue_key, topic) do
    Agent.update(__MODULE__, &Map.put(&1, topic, issue_key))
  end
end
