defmodule Estimator.Web.PageController do
  use Estimator.Web, :controller

  plug Ueberauth

  def index(conn, _params) do
    render conn, "index.html", current_user: get_session(conn, :current_user)
  end
end
