defmodule Life.GridTest do
  use ExUnit.Case, async: true
  alias Life.Grid
  alias Life.Grids

  test "empty board stays empty" do
    assert Grid.calc_next_grid(Grids.empty_grid()) == Grids.empty_grid()
  end

  test "blinker one generation" do
    assert Grid.calc_next_grid(Grids.blinker()) == MapSet.new([{0, -1}, {0, 0}, {0, 1}])
  end

  test "blinker two generation loop" do
    blinker =
      Grids.blinker()
      |> Grid.calc_next_grid()
      |> Grid.calc_next_grid()

    assert blinker == Grids.blinker()
  end

  test "transpose" do
    assert Grids.transpose(Grids.blinker(), {3, 4}) == MapSet.new([{2, 4}, {3, 4}, {4, 4}])
  end

  test "add cell" do
    grid =
      Grids.empty_grid()
      |> Grids.add_cell({1, 0})
      |> Grids.add_cell({1, 0})
      |> Grids.add_cell({0, 0})

    assert grid == MapSet.new([{0, 0}, {1, 0}])
  end

  test "add cells" do
    grid =
      Grids.empty_grid()
      |> Grids.add_cells(Grids.blinker())

    assert grid == MapSet.new([{-1, 0}, {0, 0}, {1, 0}])

  end

end