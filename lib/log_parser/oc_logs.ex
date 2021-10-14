defmodule LogParser.OCLogs do
  use GenServer
  require Logger

  alias LogParser.Parser

  @command "oc logs deploy/waf --prefix=true --follow"

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
