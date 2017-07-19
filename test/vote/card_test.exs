defmodule Estimator.Vote.CardTest do
  use ExUnit.Case
  alias Estimator.Vote.Card

  test "convert card to number" do
    assert Card.to_number("XS") == 1
    assert Card.to_number("S") == 2
    assert Card.to_number("M") == 4
    assert Card.to_number("L") == 8
    assert Card.to_number("XL") == 16
  end

  test "convert number to card" do
    assert Card.to_card(1) == "XS"
    assert Card.to_card(2) == "S"
    assert Card.to_card(4) == "M"
    assert Card.to_card(8) == "L"
    assert Card.to_card(16) == "XL"
  end
end