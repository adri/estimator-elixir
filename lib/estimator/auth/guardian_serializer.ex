defmodule Estimator.Auth.GuardianSerializer do
  @behaviour Guardian.Serializer

  def for_token(user) do
    {:ok, "User:#{user.id}"}
  end

  def from_token("User:" <> id) do
    {:ok, id}
  end

  def from_token(_) do
    {:error, "Unknown resource type"}
  end
end
