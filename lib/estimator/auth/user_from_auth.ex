defmodule Estimator.User.UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  alias Ueberauth.Auth

  def find_or_create(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp basic_info(auth) do
    %{
      id: auth.uid,
      name: auth.info.name || auth.info.nickname,
      avatar: auth.info.urls.avatar_url
    }
  end
end
