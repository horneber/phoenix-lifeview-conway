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
          <button phx-click="start_auto">Start auto</button>
          <button phx-click="stop_auto">Stop auto</button>
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

  def handle_event("toggle", value,  %{assigns: %{ grid: grid}} = socket) do
    {x, "," <> rest} = Integer.parse(value)
    {y, _} = Integer.parse(rest)
    grid = Life.Grids.toggle_cell(grid, {x, y})
    {:noreply, assign(socket, grid: grid)}
  end

  def handle_event("next_gen", _value, socket) do
    handle_info(:next_gen, socket)
  end

  def handle_event("start_auto", _value,  %{assigns: %{ tref: tref}} = socket) when is_nil(tref) do
    start_auto(socket)
  end

  def handle_event("start_auto", _value,  %{assigns: %{ tref: _tref,}} = socket) do
    Logger.debug "Start_auto with tref"
    {:noreply, socket}
  end

  def handle_event("start_auto", _value,  socket) do
    start_auto(socket)
  end

  def start_auto(socket) do
    {:ok, tref} = :timer.send_interval(500, self(), :next_gen)
    {:noreply, assign(socket, tref: tref)}
  end



  def handle_event("stop_auto", _value,  %{assigns: %{ tref: tref}} = socket) do
    :timer.cancel(tref)
#    socket = update_in(socket.assigns, &Map.drop(&1, [:tref]))
    {:noreply, update(socket, :tref, fn _ -> nil end)}
  end

  def handle_event("stop_auto", _value,  %{assigns: %{ tref: tref}} = socket) when is_nil(tref) do
    Logger.debug "Stop_auto without tref and nil"
    {:noreply, socket}
  end

  def handle_event("stop_auto", _value,  socket) do
    Logger.debug "Stop_auto without tref"
    {:noreply, socket}
  end

  def handle_info(:next_gen, %{assigns: %{ grid: grid, generation: generation }} = socket) do
    # Logger.debug "next_gen for #{inspect(grid)}}"
    next_grid = Grid.calc_next_grid(grid)
    # Logger.debug "next_gen is #{inspect(next_grid)}}"
    {:noreply, assign(socket, generation: generation + 1, grid: next_grid)}
  end

end