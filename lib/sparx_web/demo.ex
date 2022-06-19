defmodule SparxWeb.Demo do
  use SparxWeb, :live_view

  def mount(_params, _, socket) do
    socket =
      socket
      |> assign(:svg, nil)
      |> assign(:numbers, "")

    {:ok, socket}
  end

  def handle_event("load-data", _, socket) do
    data =
      Enum.reduce(1..30, "", fn _n, str ->
        str <> " " <> Integer.to_string(:rand.uniform(50))
        |> String.trim()
      end)


    {:noreply, assign(socket, :numbers, data)}
  end

  def handle_event("get-numbers", %{"numbers" => numbers}, socket) do
    points =
      numbers
      |> String.split(" ")
      |> Enum.filter(fn n -> n != "" end)
      |> Enum.map(&String.to_integer/1)
      |> build_points()

    svg = svg(%{points: points})

    socket =
      socket
      |> assign(:svg, svg)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Demo Page for Sparx</h1>
    <button type="button" phx-click="load-data" name="load data">Load Random Numbers</button>

    <form phx-change="get-numbers">

    <label for="numbers">Enter numbers separated by spaces</label>
    <input type="text" name="numbers" value={"#{@numbers}"} />


    </form>
    <h2>Numbers entered</h2>
    <%= @svg %>

    """
  end

  def svg([]) do
    assigns = []

    ~H"""
    Waiting for input
    """
  end

  def svg(assigns) do
    ~H"""
    <svg viewBox="0 0 100% 100%" xmlns="http://www.w3.org/2000/svg" style="width: 600px;height: 100px;border: 1px solid #ddd;">
    <g color="green">
    <%= for p <- @points do %>
    <rect x={"#{p.x}%"} y={"#{p.y}%"} width={"#{p.width}%"} height={"#{p.height}%"} fill="currentcolor" />
    <% end %>
    </g>
    </svg>
    """
  end

  def build_points(numbers) do
    {min, max} =
      case Enum.min_max(numbers) do
        {a, a} -> {0, 1}
        a -> a
      end

    size = length(numbers)

    gap =
      case size do
        1 -> 0
        p -> 10 / (p - 1)
      end

    report_height = max - min

    {points, _x} =
      Enum.reduce(numbers, {[], 0}, fn n, {shapes, x} ->
        gap =
          if length(numbers) == x + 1 do
            0
          else
            gap
          end

        {[
           %{
             height: 100 * ((n - min) / report_height),
             width: 1 / size * 100 - gap,
             y: 100 - 100 * ((n - min) / report_height),
             x: x * (1 / size * 100)
           }
           | shapes
         ], x + 1}
      end)

    points
  end
end
