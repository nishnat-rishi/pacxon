lume = require('lume')
timer = require('timer')

function love.load()
  map_size = {x = 20, y = 15}
  dim = 40
  -- map = {}
  -- for i = 1, map_size do
  --   map[i] = {}
  --   for j = 1, map_size do
  --     map[i][j] = 0
  --   end
  -- end
  map = {}
  reset_map()

  pathway = {}

  player = {x = 3, y = 1}

  direction = {x = 0, y = 0}

  ticker = timer:create{
    id = 'ticker',
    periodic = true,
    period = 0.13, -- seconds
    callback = on_tick,
  }

  active_q = false
end

paint_region = coroutine.create(function (stack, color_id)
  while #stack > 0 do
    pos = table.remove(stack)
    map[pos.x][pos.y] = color_id
    if map[pos.x+1][pos.y] == 0 then
      table.insert(stack, {x = pos.x+1, y = pos.y})
    end
    if map[pos.x][pos.y+1] == 0 then
      table.insert(stack, {x = pos.x, y = pos.y+1})
    end
    if map[pos.x-1][pos.y] == 0 then
      table.insert(stack, {x = pos.x-1, y = pos.y})
    end
    if map[pos.x][pos.y-1] == 0 then
      table.insert(stack, {x = pos.x, y = pos.y-1})
    end
    coroutine.yield()
  end
end)

function reset_map()
  for i = 1, map_size.x do
    map[i] = {}
    for j = 1, map_size.y do
      if j == 1 or j == map_size.y or i == 1 or i == map_size.x then
        map[i][j] = 1
      else
        map[i][j] = 0
      end
    end
  end
end

function on_tick()

  if love.keyboard.isDown('left', 'right', 'up', 'down') then
    prev_pos = {x = player.x, y = player.y}
    prev_location = map[prev_pos.x][prev_pos.y]
  end
  if love.keyboard.isDown('left') and direction.x ~= 1 then
    direction.x, direction.y = -1, 0
    key_pressed = true
  elseif love.keyboard.isDown('right') and direction.x ~= -1 then
    direction.x, direction.y = 1, 0
    key_pressed = true
  elseif love.keyboard.isDown('up') and direction.y ~= 1 then
    direction.x, direction.y = 0, -1
    key_pressed = true
  elseif love.keyboard.isDown('down') and direction.y ~= -1 then
    direction.x, direction.y = 0, 1
    key_pressed = true
  end
    player.x, player.y = lume.clamp(player.x + direction.x, 1, map_size.x), lume.clamp(player.y + direction.y, 1, map_size.y)


    if key_pressed then
    curr_location = map[player.x][player.y]

      if prev_location == 1 and curr_location == 0 then
        map[prev_pos.x][prev_pos.y] = 2
        pathway[#pathway + 1] = {x = prev_pos.x, y = prev_pos.y}

        -- Do the thing
        if active_q then
          coroutine.resume(paint_region, {player})
        end

        map[player.x][player.y] = 3
        pathway[#pathway + 1] = {x = player.x, y = player.y}
        
      elseif prev_location == 3 and curr_location == 0 then
        map[player.x][player.y] = 3
        pathway[#pathway + 1] = {x = player.x, y = player.y}
      elseif prev_location == 3 and (curr_location == 1 or curr_location == 2) then
        for _, location in pairs(pathway) do
          map[location.x][location.y] = 1
        end
        lume.clear(pathway)
      end

      direction.x, direction.y = 0, 0
      key_pressed = false
  end
end

function love.update(dt)
  timer:update(dt)
end

function love.draw()
  for i = 1, map_size.x do
    for j = 1, map_size.y do
      if map[i][j] == 0 then
        love.graphics.setColor(0.63, 0.69, 0.76)
      elseif map[i][j] == 1 then
        love.graphics.setColor(0.29, 0.60, 0.94)
      elseif map[i][j] == 2 then
        love.graphics.setColor(0.57, 0.80, 0.98)
      elseif map[i][j] == 3 then
        love.graphics.setColor(0.97, 0.56, 0.49)
      elseif map[i][j] == 4 then
        love.graphics.setColor(0.53, 0.74, 0.42)
      elseif map[i][j] == 5 then
        love.graphics.setColor(0.70, 0.48, 0.37)
      end
      love.graphics.rectangle('fill', (i-1) * dim, (j-1) * dim, dim, dim)
    end
  end
  love.graphics.setColor(0.91, 0.92, 0.46)
  love.graphics.rectangle('fill', (player.x-1) * dim, (player.y-1) * dim, dim, dim)

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format('%d\n%d\n%d\n%d\n%s\n%s', direction.x, direction.y, map[player.x][player.y], #pathway, active_q, coroutine.status(paint_region)), 10, 10)
end

function love.keypressed(key)
  if key == 'r' then
    active_q = not active_q
  elseif key == 'n' then
    coroutine.resume(paint_region)
  end
end