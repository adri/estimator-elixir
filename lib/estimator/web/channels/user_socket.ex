defmodule Estimator.Web.UserSocket do
  use Phoenix.Socket
  import Guardian.Phoenix.Socket

  ## Channels
  channel "estimation:*", Estimator.Web.EstimationChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
      timeout: 45_000

  def connect(%{"user" => user, "guardian_token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, socket, _guardian} -> {:ok, assign(socket, :user, user)}
      _ -> :error
    end
  end

  def connect(_params, _socket) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Estimator.Web.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
