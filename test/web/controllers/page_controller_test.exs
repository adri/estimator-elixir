defmodule Estimator.Web.PageControllerTest do
  use Estimator.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200) =~ "Login"
  end
end
