defmodule Welford.Twin do
  use GenServer

  alias Welford.{Variance, VarianceState}

  def start_link(id, _opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: {:global, id})
  end

  def init([]) do
    # Simple example of tracking multiple windows, e.g., 24 hours
    state = Enum.into(0..23, %{}, fn k -> {k, VarianceState.new()} end)
    {:ok, state}
  end

  def update(id, hour, new_value) do
    GenServer.call({:global, id}, {:update, hour, new_value})
  end

  def finalize(id, hour) do
    GenServer.call({:global, id}, {:finalize, hour})
  end

  def handle_call({:update, hour, new_value}, _from, state) do
    hour_state = Map.get(state, hour)
    new_hour_state = Variance.update(hour_state, new_value)

    {:reply, :ok, Map.put(state, hour, new_hour_state)}
  end

  def handle_call({:finalize, hour}, _from, state) do
    hour_state = Map.get(state, hour)
    reply = Variance.finalize(hour_state)

    {:reply, reply, state}
  end
end
