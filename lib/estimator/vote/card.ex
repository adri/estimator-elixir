defmodule Estimator.Vote.Card do
  @card_map %{
    "XS" => 1,
    "S" => 2,
    "M" => 4,
    "L" => 8,
    "XL" => 16,
  }

  def to_number(card) do
    @card_map[card]
  end

  def to_card(estimation) do
    case Enum.find(@card_map, fn {_key, value} -> value == estimation end) do
      {card, _value} -> card
      _ -> ""
    end
  end
end
