defmodule Parser do
  def parse(string) do
    {:nomatch, nil, string}
    |> check(:warning)
    |> check(:error)
  end

  defp check({:match, _, _} = input, _), do: input

  defp check({:nomatch, nil, string}, :warning) do
    if string =~ ~r{ModSecurity: Warning} do
      {:match, :warning, string}
    else
      {:nomatch, nil, string}
    end
  end

  defp check({:nomatch, nil, string}, :error) do
    if string =~ ~r{Anomaly Score Exceeded} do
      {:match, :error, string}
    else
      {:nomatch, nil, string}
    end
  end
end

defmodule OCLogs do
  use GenServer
  require Logger

  # @command "oc logs deploy/waf --prefix=true --follow"
  @command "oc logs deploy/waf --follow"

  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(_args \\ []) do
    Port.open({:spawn, @command}, [:binary, :exit_status])

    {:ok, %{latest_output: nil, exit_status: nil}}
  end

  def handle_info({_, {:data, text}}, state) do
    latest_output =
      for line <- String.split(text, "\n") do
        line
        |> String.trim()
        |> Parser.parse()
        |> log_or_discard
      end

    {:noreply, %{state | latest_output: latest_output}}
  end

  def handle_info({_, {:exit_status, status}}, state) do
    new_state = %{state | exit_status: status}
    {:noreply, new_state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp log_or_discard({:match, :warning, string}), do: Logger.warn(string)
  defp log_or_discard({:match, :error, string}), do: Logger.error(string)
  defp log_or_discard(_), do: nil
end

OCLogs.start_link()
