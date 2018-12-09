defmodule Instruction do
  @step_count 26

  # Step takes 60s + position in alphabet (A -> 61s, b -> 62s ..)
  def get_time_for_5_workers() do
    workers = List.duplicate({"", -1}, 5)

    work_time(-1, workers, [], get_input_as_instructions())
  end

  def work_time(time_taken, workers, steps_taken, instructions) do
    if length(steps_taken) < @step_count do
      completed_steps =
        Enum.reduce(workers, [], fn {task, time_finished}, acc ->
          if task != "" and time_finished <= time_taken do
            [task | acc]
          else
            acc
          end
        end)

      steps_taken = completed_steps ++ steps_taken

      workers =
        workers
        |> Enum.map(fn {task, time_finished} = _worker ->
          if task != "" and time_finished <= time_taken do
            {"", -1}
          else
            {task, time_finished}
          end
        end)

      next_steps = get_possible_next_steps_sorted(instructions, steps_taken)

      {workers, newly_active_steps} =
        next_steps
        |> Enum.reduce({workers, []}, fn step, {workers, newly_active_steps} ->
          free_worker =
            Enum.find(workers, nil, fn {task, _} ->
              task == ""
            end)

          case free_worker do
            nil ->
              {workers, newly_active_steps}

            free_worker ->
              # remove idle worker and add new worker doing the new step
              {[{step, time_taken + get_time(step)} | List.delete(workers, free_worker)],
               [step | newly_active_steps]}
          end
        end)

      instructions =
        newly_active_steps
        |> Enum.reduce(instructions, fn task, acc ->
          Map.delete(acc, task)
        end)

      work_time(time_taken + 1, workers, steps_taken, instructions)
    else
      time_taken
    end
  end

  def get_time(step), do: 60 + (step |> to_charlist |> List.first()) - 64

  def determine_order() do
    get_input_as_instructions()
    |> take_steps([])
  end

  def take_steps(instructions, steps_taken) do
    if length(steps_taken) < @step_count do
      next_step = add_step(instructions, steps_taken)
      instructions = Map.delete(instructions, next_step)
      take_steps(instructions, [next_step | steps_taken])
    else
      steps_taken |> Enum.reverse() |> Enum.join("")
    end
  end

  def add_step(instructions, steps_taken) do
    instructions
    |> get_possible_next_steps_sorted(steps_taken)
    |> List.first()
  end

  def get_possible_next_steps_sorted(instructions, steps_taken) do
    instructions
    |> Enum.reduce([], fn {step, required}, possible_next_steps ->
      if required -- steps_taken == [] do
        [step | possible_next_steps]
      else
        possible_next_steps
      end
    end)
    |> Enum.sort()
  end

  def get_input_as_instructions() do
    get_input_as_list()
    |> Enum.map(&String.split/1)
    |> Enum.reduce(%{"C" => [], "G" => [], "U" => [], "X" => []}, fn split_line, acc ->
      step = Enum.at(split_line, 7)
      requires = Enum.at(split_line, 1)

      Map.update(acc, step, [requires], fn requires_list -> [requires | requires_list] end)
    end)
  end

  def get_input_as_list() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() end)
  end
end

# 1047 too high
# 1033 too low
