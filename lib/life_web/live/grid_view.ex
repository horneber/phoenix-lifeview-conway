defmodule LifeWeb.GridView do
  use Phoenix.LiveView
  require Logger
  alias Life.Grid
  def render(assigns) do
    ~L"""
    <div class="container">
      <%= for y <- -100..100 do %>
        <div class="row">
          <%= for x <- -100..100 do %>
          <div class="column"><%= if MapSet.member?(@grid, {x,y}), do: "X", else: " " %> </div>
          <% end %>
        </div>
        <% end %>
    </div>
    <div class="">
      <div>
        <div>
          <button phx-click="next_gen">Next Generation</button>
          <button phx-click="auto">Start auto</button>
        </div>
        Status: <%= @generation %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    Logger.debug "Mounting!"
    {:ok, assign(socket, generation: 0, grid: Life.Grids.gosper_glider())}
  end

  def handle_event("next_gen", _value, socket) do
    handle_info(:next_gen, socket)
  end

  def handle_event("auto", _value,  socket) do
    :timer.send_interval(200, self(), :next_gen)
    {:noreply, socket}
  end

  def handle_info(:next_gen, %{assigns: %{ grid: grid, generation: generation }} = socket) do
    # do the deploy process
    Logger.debug "next_gen for #{inspect(grid)}}"
    next_grid = Grid.calc_next_grid(grid)
    Logger.debug "next_gen is #{inspect(next_grid)}}"
    {:noreply, assign(socket, generation: generation + 1, grid: next_grid)}
  end

end