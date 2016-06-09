defmodule RGBMonitor.Server do
  use GenServer
  alias RGBMonitor.{Color, Const, Sensor}
  require Const
  use Bitwise

  defmodule State do
    defstruct [
      pid: nil,
      integration_time: Const.integration_time_700ms,
      gain: Const.gain_1x,
      delay: nil
    ]
  end

  def start_link(params \\ [], opts \\ []) do
    state = struct(%State{}, params)
    device = Keyword.get(params, :dev_name, "i2c-1")
    address = Keyword.get(params, :address, Const.address)
    GenServer.start_link(__MODULE__, [device, address, state], opts)
  end

  def init([device, address, state]) do
    {:ok, pid} = I2c.start_link(device, address)
    if Sensor.available?(pid) do
      send(self, :init_sensor)
      {:ok, %{state | pid: pid}}
    else
      {:stop, "Sensor not connected"}
    end
  end

  def handle_info(:init_sensor, %{pid: pid} = state) do
    Sensor.set_integration_time(pid, state.integration_time)
    Sensor.set_gain(pid, state.gain)
    Sensor.enable(pid)
    send(self, :read)
    {:noreply, %{state | delay: Sensor.delay(state.integration_time)}}
  end
  def handle_info(:read, %{pid: pid} = state) do
    {c, r, g, b} = Sensor.read(pid)
    IO.puts "Temp: #{Color.calc_temperature(r, g, b)}"
    IO.puts "Lux: #{Color.calc_lux(r, g, b)}"
    Process.send_after(self, :read, state.delay)
    {:noreply, state}
  end
 end
