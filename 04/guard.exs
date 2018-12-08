defmodule Record do
  defstruct id: nil, action: :none, month: nil, day: nil, hour: nil, minute: nil
end

defmodule Guard do
  def get_guard_most_frequently_asleep_same_minute() do
    {guard, minute, _} =
      get_input_as_ordered_records()
      |> get_sleep_intervals_by_guard()
      |> sleep_intervals_to_minute_lists_by_guard()
      |> to_list_of_ids_minutes_counts()
      |> Enum.max_by(fn {id, minute, count} -> count end)
      |> IO.inspect()

    guard * minute
  end

  def to_list_of_ids_minutes_counts(sleep_minutes_by_guard) do
    sleep_minutes_by_guard
    |> Enum.map(fn {id, sleep_minutes} ->
      {minute, count} =
        sleep_minutes
        |> Enum.reduce(%{}, fn minute, acc ->
          Map.update(acc, minute, 1, &(&1 + 1))
        end)
        |> Enum.max_by(fn {minute, count} -> count end)

      {id, minute, count}
    end)
  end

  def get_guard_sleep_amount() do
    sleep_minutes_by_guard =
      get_input_as_ordered_records()
      |> get_sleep_intervals_by_guard()
      |> sleep_intervals_to_minute_lists_by_guard()

    longest_sleeping_guard =
      sleep_minutes_by_guard
      |> get_longest_sleeping_guard()
      |> IO.inspect()

    longest_minute =
      get_longest_minute_for_guard(Map.get(sleep_minutes_by_guard, longest_sleeping_guard))
      |> IO.inspect()

    longest_minute * longest_sleeping_guard
  end

  def get_longest_minute_for_guard(sleep_minutes) do
    sleep_minutes
    |> Enum.reduce(%{}, fn minute, acc ->
      Map.update(acc, minute, 1, &(&1 + 1))
    end)
    |> Enum.max_by(fn {minute, count} -> count end)
    |> elem(0)
  end

  def get_longest_sleeping_guard(sleep_minutes_by_guard) do
    sleep_minutes_by_guard
    |> Enum.max_by(fn {id, minutes} -> length(minutes) end)
    |> elem(0)
  end

  def get_sleep_intervals_by_guard(records) do
    records
    |> Enum.reduce({-1, %{}, nil}, fn record, {active_guard, sleep_map, asleep_from} ->
      case record.action do
        # TODO: check if you use sleep / wake up minutes as intended or need to +/- 1
        :wakes_up ->
          {active_guard,
           Map.update(sleep_map, active_guard, [], fn sleep_list ->
             [{asleep_from, record.minute - 1} | sleep_list]
           end), nil}

        :falls_asleep ->
          {active_guard, sleep_map, record.minute}

        :begins_shift ->
          {record.id, sleep_map, asleep_from}

        other ->
          IO.puts("FAULTY RECORD!")
          IO.inspect(record)
      end
    end)
    |> elem(1)
  end

  def sleep_intervals_to_minute_lists_by_guard(intervals_by_guard) do
    intervals_by_guard
    |> Enum.map(fn {id, sleep_intervals} ->
      minute_list =
        sleep_intervals
        |> Enum.flat_map(fn {from, to} -> from..to end)

      {id, minute_list}
    end)
    |> Enum.into(%{})
  end

  def get_input_as_ordered_records() do
    get_input_as_list()
    |> Enum.sort()
    |> Enum.map(&to_record/1)
  end

  def to_record(
        "[" <>
          <<_year::bytes-size(4)>> <>
          "-" <>
          <<month::bytes-size(2)>> <>
          "-" <>
          <<day::bytes-size(2)>> <>
          " " <> <<hour::bytes-size(2)>> <> ":" <> <<minute::bytes-size(2)>> <> "] " <> text
      ) do
    cond do
      String.contains?(text, "wakes up") ->
        %Record{
          action: :wakes_up,
          month: String.to_integer(month),
          day: String.to_integer(day),
          hour: String.to_integer(hour),
          minute: String.to_integer(minute)
        }

      String.contains?(text, "falls asleep") ->
        %Record{
          action: :falls_asleep,
          month: String.to_integer(month),
          day: String.to_integer(day),
          hour: String.to_integer(hour),
          minute: String.to_integer(minute)
        }

      String.contains?(text, "Guard #") ->
        %Record{
          id: text |> String.replace(~r/[^\d]/, "") |> String.to_integer(),
          action: :begins_shift,
          month: String.to_integer(month),
          day: String.to_integer(day),
          hour: String.to_integer(hour),
          minute: String.to_integer(minute)
        }
    end
  end

  def get_input_as_list() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(&String.trim/1)
  end
end

# Idea:

# Turn input into rectangle structs,
# do rectangle collisions,
# find colliding points and add them to a hashset,
# count hashset
