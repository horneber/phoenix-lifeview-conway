defmodule Life.GridTest do
  use ExUnit.Case, async: true
  alias Life.Grid
  alias Life.Grids

  test "empty board stays empty" do
    assert Grid.calc_next_grid(Grids.empty_grid()) == Grids.empty_grid()
  end

  test "blinker one generation" do
    assert Grid.calc_next_grid(Grids.blinker()) == MapSet.new([{1, 3}, {2, 3}, {3, 3}])
  end

  test "blinker two generation loop" do
    blinker =
      Grids.blinker()
      |> Grid.calc_next_grid()
      |> Grid.calc_next_grid()

    assert blinker == Grids.blinker()
  end

  test "transpose" do
    assert Grids.transpose(Grids.blinker(), {1,2}) == MapSet.new([{3, 4}, {3, 5}, {3, 6}])
  end

end