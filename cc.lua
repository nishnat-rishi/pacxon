repeat
  f = io.read('l')
  if f == '' then
    break
  end
  r, g, b = string.match(f, '(%d+), (%d+), (%d+)')
  print(string.format('%.2f, %.2f, %.2f', r/255, g/255, b/255))
until false