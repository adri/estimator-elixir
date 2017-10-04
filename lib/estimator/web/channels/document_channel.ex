defmodule Estimator.Web.DocumentChannel do
  use Estimator.Web, :channel
  @topic_prefix "document:"

  def join(@topic_prefix <> document_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("text_change", params, socket) do
    broadcast_from socket, "text_change", %{
      delta: params["delta"],
    }

    {:reply, :ok, socket}
  end

end
