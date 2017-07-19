defmodule Estimator.Integration.EstimationTest do
  use Estimator.IntegrationCase, async: true

  import Wallaby.Query, only: [css: 2]

  @page "/board/1/estimate"

  test "users can see other votes" do
    {:ok, user1} = Wallaby.start_session
    user1
    |> visit(@page <> "?kitty")

    {:ok, user2} = Wallaby.start_session
    user2
    |> visit(@page <> "?bean")

    user1
    |> assert_has(css(".player", text: "Mr. Bean"))

    user2
    |> assert_has(css(".player", text: "Kitty"))
  end

end