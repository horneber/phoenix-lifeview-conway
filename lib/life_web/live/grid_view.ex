defmodule LifeWeb.GridView do
  use Phoenix.LiveView
  require Logger
  alias Life.Grid

  @board_size 100
  def render(assigns) do
    board_size = @board_size
    ~L"""
    <table  >
      <%= for y <- board_size..1 do %>
        <tr>
          <%= for x <- 1..board_size do %>
            <td class="<%= if MapSet.member?(@grid, {x,y}), do: "alive", else: "dead" %>" phx-click="toggle" phx-value="<%= x %>,<%= y %>"></td>
          <% end %>
        </tr>
      <% end %>
    </table>
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
    {:ok, assign(socket, generation: 0, grid: Life.Grids.interesting_starter())}
  end

  def handle_event("toggle", value,  %{assigns: %{ grid: grid, generation: _generation }} = socket) do
    Logger.debug "Toggle #{inspect(value)}}"
    {x, "," <> rest} = Integer.parse(value)
    Logger.debug "X #{inspect(x)}"
    Logger.debug "rest #{inspect(rest)}"
    {y, _} = Integer.parse(rest)
    Logger.debug "Y #{inspect(y)}"
    grid = Life.Grids.toggle_cell(grid, {x, y})
    {:noreply, assign(socket, grid: grid)}
  end

  def handle_event("next_gen", _value, socket) do
    handle_info(:next_gen, socket)
  end

  def handle_event("auto", _value,  socket) do
    :timer.send_interval(500, self(), :next_gen)
    {:noreply, socket}
  end

  def handle_info(:next_gen, %{assigns: %{ grid: grid, generation: generation }} = socket) do
    # do the deploy process
    # Logger.debug "next_gen for #{inspect(grid)}}"
    next_grid = Grid.calc_next_grid(grid)
    # Logger.debug "next_gen is #{inspect(next_grid)}}"
    {:noreply, assign(socket, generation: generation + 1, grid: next_grid)}
  end

end