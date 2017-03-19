defmodule Estimator.User.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  alias Ueberauth.Auth

  def find_or_create(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp basic_info(auth) do
    IO.inspect auth
    %{id: auth.uid, name: name_from_auth(auth), avatar: auth.info.urls.avatar_url}
  end

  defp name_from_auth(auth) do
    auth.info.name
  end
end
