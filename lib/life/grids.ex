defmodule Life.Grids do

  def empty_grid, do: MapSet.new

  def blinker, do: MapSet.new([{-1, 0}, {0, 0}, {1, 0}])

  def gosper_glider do
    MapSet.new(
      [
        {24, 8},
        {22, 7},
        {24, 7},
        {12, 6},
        {13, 6},
        {20, 6},
        {21, 6},
        {34, 6},
        {35, 6},
        {11, 5},
        {15, 5},
        {20, 5},
        {21, 5},
        {34, 5},
        {35, 5},
        {0, 4},
        {1, 4},
        {10, 4},
        {16, 4},
        {20, 4},
        {21, 4},
        {0, 3},
        {1, 3},
        {10, 3},
        {14, 3},
        {16, 3},
        {17, 3},
        {22, 3},
        {24, 3},
        {10, 2},
        {16, 2},
        {24, 2},
        {11, 1},
        {15, 1},
        {12, 0},
        {13, 0},
      ]
    )
  end

  def gun do
    gosper_glider()
    |> transpose({0, 90})
    |> mirror()
  end

  def transpose(grid, {x_offset, y_offset}) do
    Enum.into(grid, MapSet.new, fn {x, y} -> {x + x_offset, y + y_offset}  end)
  end

  def mirror(grid) do
    Enum.into(grid, MapSet.new, fn {x, y} -> {y, x}  end)
  end

  def add_cells(grid, cells), do: MapSet.union(grid, cells)
  def add_cell(grid, {_x, _y} = cell), do: MapSet.put(grid, cell)

  def interesting_starter do
    blinker_left = transpose(blinker(), {10, 90})
    blinker_right = transpose(blinker(), {90, 90})
    blinker_center = transpose(blinker(), {50, 50})
    penta = transpose(Life.Patterns.Oscillators.pentadecathlon(), {40, 80})
    bees = transpose(Life.Patterns.StillLife.beehive(), {70, 10})
    gosper_glider()
    |> transpose({0, 90})
    |> mirror()
    |> add_cells(blinker_left)
    |> add_cells(blinker_right)
    |> add_cells(blinker_center)
    |> add_cells(penta)
    |> add_cells(bees)

  end
end