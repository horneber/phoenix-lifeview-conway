defmodule LifeWeb.PageView do
  use LifeWeb, :view

  def board_size(), do: floor(:math.sqrt(20_000))
end
