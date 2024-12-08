defmodule AssertHelpers do
  @doc """
  Repeatedly evaluates a function until it returns true or timeout is reached.

  This helper is useful for asynchronous tests where you need to wait for a condition
  to become true over time.

  ## Parameters

    * `fun` - A function that returns boolean, representing the condition to check
    * `timeout_ms` - Maximum time to wait in milliseconds (default: 1000)
    * `interval_ms` - Time between checks in milliseconds (default: 100)

  ## Returns

    * `true` - If the condition is met within the timeout period
    * `false` - If the timeout is reached before the condition is met

  ## Examples

      # With custom timeout and interval
      eventually(fn ->
        state.ready? == true
      end, 5000, 500)
  """

  def eventually(fun, timeout_ms \\ 1000, interval_ms \\ 100) do
    start_time = current_time = System.monotonic_time(:millisecond)

    loop(fun, start_time, current_time, timeout_ms, interval_ms)
  end

  defp loop(_fun, start_time, current_time, timeout_ms, _interval_ms)
       when current_time - start_time > timeout_ms do
    "Condition not met within #{timeout_ms}ms"
    false
  end

  defp loop(fun, start_time, _current_time, timeout_ms, interval_ms) do
    case fun.() do
      true ->
        true

      false ->
        Process.sleep(interval_ms)
        new_current_time = System.monotonic_time(:millisecond)
        loop(fun, start_time, new_current_time, timeout_ms, interval_ms)
    end
  end
end
