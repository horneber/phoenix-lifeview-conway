defmodule Life.BoardTest do
  use ExUnit.Case, async: true
  alias Life.Board

  test "empty board" do
    Board.calc_next_grid([])
  end
end