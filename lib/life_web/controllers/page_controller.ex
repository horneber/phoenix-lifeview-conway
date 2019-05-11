defmodule LifeWeb.PageController do
  use LifeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
