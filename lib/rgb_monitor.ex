defmodule RGBMonitor do
  use GenServer
  alias RGBMonitor.Color
  alias TCS34725.Const
  require Const
  use Bitwise

  defmodule State do
    defstruct [
      bus: "i2c-1",
      address: Const.address,
      pid: nil,
      integration_time: Const.integration_time_700ms,
      gain: Const.gain_1x,
      delay: nil,
      pubsub: nil,
      enabled: true
    ]
  end

  def start_link(params \\ [], opts \\ []) do
    state = struct(%State{}, params)
    GenServer.start_link(__MODULE__, [state], opts)
  end

  def enable(pid) do
    GenServer.cast(pid, :enable)
  end

  def disable(pid) do
    GenServer.cast(pid, :disable)
  end

  def set_pubsub(pid, pubsub) do
    GenServer.cast(pid, {:set_pubsub, pubsub})
  end

  def init([state]) do
    {:ok, pid} = I2c.start_link(state.bus, state.address)
    if TCS34725.available?(pid) do
      send(self, :init_sensor)
      {:ok, %{state | pid: pid}}
    else
      {:stop, "Sensor not connected"}
    end
  end

  def handle_cast(:enable, %{enabled: false} = state) do
    TCS34725.enable(state.pid)
    send(self, :read)
    {:noreply, %{state | enabled: true}}
  end
  def handle_cast(:enable, state) do
    {:noreply, state}
  end
  def handle_cast(:disable, %{enabled: true} = state) do
    TCS34725.disable(state.pid)
    {:noreply, %{state | enabled: false}}
  end
  def handle_cast(:disable, state) do
    {:noreply, state}
  end
  def handle_cast({:set_pubsub, pubsub}, state) do
    {:noreply, %{state | pubsub: pubsub}}
  end

  def handle_info(:init_sensor, %{pid: pid} = state) do
    TCS34725.set_integration_time(pid, state.integration_time)
    TCS34725.set_gain(pid, state.gain)
    TCS34725.enable(pid)
    send(self, :read)
    {:noreply, %{state | delay: TCS34725.delay(state.integration_time)}}
  end
  def handle_info(:read, %{enabled: true} = state) do
    maybe_read_broadcast(state)
    Process.send_after(self, :read, state.delay)
    {:noreply, state}
  end
  def handle_info(:read, %{enabled: false} = state) do
    {:noreply, state}
  end

  defp maybe_read_broadcast(%{pubsub: nil}), do: nil
  defp maybe_read_broadcast(state) do
    raw = TCS34725.read(state.pid)
    message = %{
      raw: raw,
      temperature: Color.calc_temperature(raw),
      lux: Color.calc_lux(raw)
    }
    Phoenix.PubSub.broadcast(state.pubsub, "light", message)
  end
 end
