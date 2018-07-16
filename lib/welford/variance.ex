defmodule Welford.Variance do
  @moduledoc """
  Functions used for calculating variance using Welford's online algorithm.
  """
  alias Welford.VarianceState

  @spec update(VarianceState.t(), number) :: VarianceState.t()
  def update(%VarianceState{} = state, new_value) do
    # Source: https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Online_algorithm
    count = state.count + 1
    delta = new_value - state.mean
    mean = state.mean + delta / count
    delta2 = new_value - mean
    m2 = state.m2 + delta * delta2

    VarianceState.new(count, mean, m2)
  end

  @spec finalize(VarianceState.t()) ::
          %{mean: float, variance: float, sample_variance: float} | {:error, term}
  def finalize(%VarianceState{count: count}) when count < 2 do
    {:error, :insufficient_count}
  end

  def finalize(%VarianceState{} = state) do
    {mean, variance, sample_variance} =
      {state.mean, state.m2 / state.count, state.m2 / (state.count - 1)}

    {:ok, %{count: state.count, mean: mean, variance: variance, sample_variance: sample_variance}}
  end

  @spec mean(VarianceState.t()) :: float | {:error, term}
  def mean(%VarianceState{} = state) do
    with {:ok, stats} <- finalize(state) do
      stats.mean
    end
  end

  @spec variance(VarianceState.t()) :: float | {:error, term}
  def variance(%VarianceState{} = state) do
    with {:ok, stats} <- finalize(state) do
      stats.variance
    end
  end

  @spec sample_variance(VarianceState.t()) :: float | {:error, term}
  def sample_variance(%VarianceState{} = state) do
    with {:ok, stats} <- finalize(state) do
      stats.sample_variance
    end
  end
end
