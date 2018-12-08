defmodule Rectangle do
  defstruct id: 0, x: 0, y: 0, x2: 0, y2: 0
end

defmodule Fabric do
  def get_non_overlapping_rectangle_id() do
    rectangles =
      get_input_as_list()
      |> to_rectangles()

    Enum.reduce_while(rectangles, {rectangles, -1}, fn rect, {rectangles, id} ->
      case get_colliding_points_for_rectangle(rect, rectangles) do
        [] -> {:halt, {[], rect.id}}
        points -> {:cont, {rectangles, -1}}
      end
    end)
    |> elem(1)
  end

  def get_overlapping_points() do
    get_input_as_list()
    |> to_rectangles()
    |> get_colliding_points()
    |> Enum.reduce(MapSet.new(), fn point, acc ->
      MapSet.put(acc, point)
    end)
    |> MapSet.size()
  end

  def to_rectangles(lines) do
    lines
    |> get_clean_input_lines()
    |> Enum.map(fn [hash_id, _, pos_str, dimensions_str] ->
      id = hash_id |> String.replace("#", "") |> String.to_integer()
      pos_str = pos_str |> String.replace(":", "")
      [x, y] = pos_str |> String.split(",") |> Enum.map(&String.to_integer/1)
      [w, h] = dimensions_str |> String.split("x") |> Enum.map(&String.to_integer/1)

      # +1 cause that's effectively how they're drawn on the website
      %Rectangle{id: id, x: x + 1, y: y + 1, x2: x + w, y2: y + h}
    end)
  end

  def get_clean_input_lines(lines) do
    # "#1 @ 483,830: 24x18" |> [#1, @, 483,830:, 24x18] |> [483,830:, 24x18]
    lines
    |> Enum.map(fn line ->
      line
      |> String.split()
    end)
  end

  def get_colliding_points_for_rectangle(rectangle, rectangles) do
    for rect <- rectangles do
      get_colliding_points(rectangle, rect)
    end
    |> List.flatten()
  end

  def get_colliding_points(rectangles) do
    for a <- rectangles,
        b <- rectangles do
      get_colliding_points(a, b)
    end
    |> List.flatten()
  end

  def get_colliding_points(rect_a, rect_a), do: []

  # catch rects that don't collide at all
  def get_colliding_points(%Rectangle{id: _, x: a_x, y: a_y, x2: a_x2, y2: a_y2}, %Rectangle{
        id: _,
        x: b_x,
        y: b_y,
        x2: b_x2,
        y2: b_y2
      })
      when b_x > a_x2 or b_y > a_y2 or a_x > b_x2 or a_y > b_y2,
      do: []

  def get_colliding_points(%Rectangle{id: _, x: a_x, y: a_y, x2: a_x2, y2: a_y2}, %Rectangle{
        id: _,
        x: b_x,
        y: b_y,
        x2: b_x2,
        y2: b_y2
      }) do
    bottom_left_x = max(a_x, b_x)
    bottom_left_y = max(a_y, b_y)

    top_right_x = min(a_x2, b_x2)
    top_right_y = min(a_y2, b_y2)

    x_range = bottom_left_x..top_right_x
    y_range = bottom_left_y..top_right_y

    for x <- x_range,
        y <- y_range do
      {x, y}
    end
  end

  def get_input_as_list() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() end)
  end
end

# Idea:

# Turn input into rectangle structs,
# do rectangle collisions,
# find colliding points and add them to a hashset,
# count hashset
