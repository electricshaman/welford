defmodule Welford.Twin do
  use GenServer

  def start_link(id, _opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: {:global, id})
  end

  def init([]) do
    {:ok, %{count: 0, mean: 0.0, m2: 0.0}}
  end

  def update(id, new_value) do
    GenServer.call({:global, id}, {:update, new_value})
  end

  def finalize(id) do
    GenServer.call({:global, id}, :finalize)
  end

  def handle_call({:update, new_value}, _from, %{count: count, mean: mean, m2: m2} = state) do
    # Source: https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm
    count = count + 1
    delta = new_value - mean
    mean = mean + delta / count
    delta2 = new_value - mean
    m2 = m2 + delta * delta2

    new_state =
      state
      |> Map.put(:count, count)
      |> Map.put(:mean, mean)
      |> Map.put(:m2, m2)

    {:reply, :ok, new_state}
  end

  def handle_call(:finalize, _from, %{count: count} = state) when count < 2 do
    {:reply, {:error, :insufficient_count}, state}
  end

  def handle_call(:finalize, _from, %{count: count, mean: mean, m2: m2} = state) do
    {mean, variance, sample_variance} = {mean, m2 / count, m2 / (count - 1)}
    stats = %{mean: mean, variance: variance, sample_variance: sample_variance}
    {:reply, {:ok, stats}, state}
  end
end
