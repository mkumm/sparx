defmodule SparxWeb.PageController do
  use SparxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
