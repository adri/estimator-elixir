defmodule Estimator.Issue.CurrentIssue do
  @moduledoc """
  Stores the currently selected issue for a topic
  """
  @name __MODULE__

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> MapSet.new end, opts)
  end

  def get_for_topic(topic, name \\ @name) do
    Agent.get(@name, &Map.get(&1, topic))
  end

  def set_for_topic(issue_key, topic, name \\ @name) do
    Agent.update(@name, &Map.put(&1, topic, issue_key))
  end
end
