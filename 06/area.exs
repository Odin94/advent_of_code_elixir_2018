defmodule Area do
  def get_region_size_of_locations_total_distance_below_10000() do
    coords = get_input_as_list_of_coords()
    {min_x, min_y, max_x, max_y} = get_boundaries(coords)

    for x <- min_x..max_x,
        y <- min_y..max_y do
      {x, y}
    end
    |> with_total_distance_to_all_coords(coords)
    |> Enum.filter(fn {_, _, total_distance} -> total_distance < 10000 end)
    |> Enum.count()
  end

  def with_total_distance_to_all_coords(grid, coords) do
    grid
    |> Enum.map(fn {g_x, g_y} ->
      total_distance =
        coords
        |> Enum.reduce(0, fn {{c_x, c_y}, i}, acc ->
          acc + get_manhattan_distance(g_x, g_y, c_x, c_y)
        end)

      {g_x, g_y, total_distance}
    end)
  end

  def get_largest_finite_area() do
    coords = get_input_as_list_of_coords()

    {min_x, min_y, max_x, max_y} = get_boundaries(coords)

    # Ignore coords that own places on the boundaries since they will have infinite areas
    coords = nil_ids_of_infinite_coords(coords, min_x, min_y, max_x, max_y)

    for x <- (min_x + 1)..(max_x - 1),
        y <- (min_y + 1)..(max_y - 1) do
      {x, y}
    end
    |> with_closest_ids(coords)
    |> Enum.reduce(%{}, fn {{_, _}, i}, acc -> Map.update(acc, i, 1, &(&1 + 1)) end)
    |> Map.delete(nil)
    |> Map.values()
    |> Enum.max()
  end

  def get_boundaries(coords) do
    {{min_x, _}, _} = coords |> Enum.min_by(fn {{x, _y}, _i} -> x end)
    {{_, min_y}, _} = coords |> Enum.min_by(fn {{_x, y}, _i} -> y end)

    {{max_x, _}, _} = coords |> Enum.max_by(fn {{x, _y}, _i} -> x end)
    {{_, max_y}, _} = coords |> Enum.max_by(fn {{_x, y}, _i} -> y end)

    {min_x, min_y, max_x, max_y}
  end

  def nil_ids_of_infinite_coords(coords, min_x, min_y, max_x, max_y) do
    boundaries =
      Enum.map(min_x..max_x, fn x -> {x, min_y} end) ++
        Enum.map(min_x..max_x, fn x -> {x, max_y} end) ++
        Enum.map(min_y..max_y, fn y -> {min_x, y} end) ++
        Enum.map(min_y..max_y, fn y -> {max_x, y} end)

    coords_to_ignore_ids =
      boundaries
      |> Enum.map(fn {c_x, c_y} ->
        get_closest_id(coords, c_x, c_y)
      end)
      |> Enum.uniq()

    Enum.map(coords, fn {{x, y}, i} ->
      if Enum.member?(coords_to_ignore_ids, i) do
        {{x, y}, nil}
      else
        {{x, y}, i}
      end
    end)
  end

  def with_closest_ids(grid, coords) do
    grid
    |> Enum.map(fn {g_x, g_y} ->
      closest_id = get_closest_id(coords, g_x, g_y)

      has_finite_area =
        coords
        |> Enum.min_by(fn {{c_x, c_y}, i} ->
          get_manhattan_distance(g_x, g_y, c_x, c_y)
        end)
        |> elem(1)

      {{g_x, g_y}, closest_id}
    end)
  end

  def get_closest_id(coords, g_x, g_y) do
    coords
    |> Enum.map(fn {{c_x, c_y}, i} ->
      {{c_x, c_y}, i, get_manhattan_distance(g_x, g_y, c_x, c_y)}
    end)
    |> Enum.sort(fn {{_, _}, _, dist_a}, {{_, _}, _, dist_b} ->
      dist_a <= dist_b
    end)
    |> (fn list ->
          case list do
            # no id if two coords are at same distance
            [{{_, _}, _, dist}, {{_, _}, _, dist} | tail] ->
              nil

            [{{_, _}, i, _} | tail] ->
              i
          end
        end).()
  end

  def get_manhattan_distance(a, b, c, d), do: abs(a - c) + abs(b - d)

  def get_input_as_list_of_coords() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() end)
    |> Enum.map(fn s ->
      s |> String.split(", ") |> Enum.map(&String.to_integer(&1)) |> List.to_tuple()
    end)
    |> Enum.with_index()
  end
end
