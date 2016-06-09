defmodule RGBMonitor.Color do

  def calc_temperature(r, g, b) do
    # map rgb to their xyz counterparts
    x = (-0.14282 * r) + (1.54924 * g) + (-0.95641 * b)
    y = (-0.32466 * r) + (1.57837 * g) + (-0.73191 * b)
    z = (-0.68202 * r) + (0.77073 * g) + ( 0.56332 * b)

    # calculate chromaticity co-ordinates
    xc = x / (x + y + z)
    yc = y / (x + y + z)

    # McCamy's formula to determine CCT
    n = (xc - 0.3320) / (0.1858 - yc)
    (449.0 * :math.pow(n, 3)) + (3525.0 * :math.pow(n, 2)) + (6823.3 * n) + 5520.33
  end

  def calc_lux(r, g, b) do
    (-0.32466 * r) + (1.57837 * g) + (-0.73191 * b)
  end
end
