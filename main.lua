--[[


Debugging tools: 
-----------------

> Near the end of the love.draw function, there are 2 debugging tools.
  > View map as numbers
  > View miscellaneous info


Bugs:
------

> (SOLVED) draw a straight line from up to down, it paints the right side blue, no matter its size.
  > Solved Note: was doing: areas[id] > max_id ... to calculate maximum area instead of the correct: areas[id] > areas[max_id]





]]-----------------------------------------------------------------------------------------------------------


lume = require('lume')
timer = require('timer')

function love.load()
  love.graphics.setFont(love.graphics.newFont('RobotoMono-Regular.ttf', 14))

  map_size = {x = 40, y = 30}
  dim = 20
  -- map = {}
  -- for i = 1, map_size do
  --   map[i] = {}
  --   for j = 1, map_size do
  --     map[i][j] = 0
  --   end
  -- end
  map = {}
  player = {}
  reset_map()

  pathway = {}

  direction = {x = 0, y = 0}

  ticker = timer:create{
    id = 'ticker',
    periodic = true,
    period = 0.08, -- seconds
    callback = on_tick,
  }

  potential_beginnings = {}

  areas = {}

  last_marked = {top = false, bottom = false, left = false, right = false}
end

function paint_region(stack, color_id)
  area = 0
  while #stack > 0 do
    pos = table.remove(stack)
    map[pos.x][pos.y] = color_id
    area = area + 1
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
    -- coroutine.yield()
  end
  return area
end

function fill_smaller_area()
  -- For all potential_beginnings, mark the map with a 4
  -- id = 4
  first_id = 20
  id = first_id
  max_id = first_id

  for _, pos in pairs(potential_beginnings) do
    if map[pos.x][pos.y] == 0 then
      -- coroutine.yield()
      areas[id] = paint_region({pos}, id)
      -- coroutine.yield()
      if areas[id] > areas[max_id] then
        max_id = id
      end
      id = id + 1
    end
  end

  lume.clear(areas)

  for i = 1, map_size.x do
    for j = 1, map_size.y do
      if map[i][j] >= 20 then
        if map[i][j] ~= max_id then
          map[i][j] = 1
        else
          map[i][j] = 0
        end
      end
    end
  end

end

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

  player = {x = 3, y = 1}
end

function on_tick()

  if love.keyboard.isDown('left', 'right', 'up', 'down') then
    prev_pos = {x = player.x, y = player.y}
    prev_location = map[prev_pos.x][prev_pos.y]
  end
  if love.keyboard.isDown('left') and direction.x ~= 1 then
    direction.x, direction.y = -1, 0
    key_pressed = 'left'
  elseif love.keyboard.isDown('right') and direction.x ~= -1 then
    direction.x, direction.y = 1, 0
    key_pressed = 'right'
  elseif love.keyboard.isDown('up') and direction.y ~= 1 then
    direction.x, direction.y = 0, -1
    key_pressed = 'up'
  elseif love.keyboard.isDown('down') and direction.y ~= -1 then
    direction.x, direction.y = 0, 1
    key_pressed = 'down'
  end


    player.x, player.y = lume.clamp(player.x + direction.x, 1, map_size.x), lume.clamp(player.y + direction.y, 1, map_size.y)

    if key_pressed then
    curr_location = map[player.x][player.y]

      if prev_location == 1 and curr_location == 0 then -- pacman has left his territory and ventured into unexplored areas
        map[prev_pos.x][prev_pos.y] = 2
        pathway[#pathway + 1] = {x = prev_pos.x, y = prev_pos.y}

        map[player.x][player.y] = 3
        pathway[#pathway + 1] = {x = player.x, y = player.y}
        
      elseif prev_location == 3 and curr_location == 0 then -- pacman has jumped from an unexplored area to another unexplored area
        map[player.x][player.y] = 3
        pathway[#pathway + 1] = {x = player.x, y = player.y}

      elseif prev_location == 3 and (curr_location == 1 or curr_location == 2) then -- pacman has returned to his territory

        for _, location in pairs(pathway) do
          if map[location.x][location.y] == 3 then
            if map[location.x + 1][location.y] == 0 then
              table.insert(potential_beginnings, {x = location.x + 1, y = location.y})
            end
            if map[location.x - 1][location.y] == 0 then
              table.insert(potential_beginnings, {x = location.x - 1, y = location.y})
            end
            if map[location.x][location.y + 1] == 0 then
              table.insert(potential_beginnings, {x = location.x, y = location.y + 1})
            end
            if map[location.x][location.y - 1] == 0 then
              table.insert(potential_beginnings, {x = location.x, y = location.y - 1})
            end
          end
          map[location.x][location.y] = 1
        end

        fill_smaller_area()

        lume.clear(potential_beginnings)
        lume.clear(pathway)

        -- Do the thing
        -- if active_q then
        --   coroutine.resume(paint_region, {player}, 4)
        -- end
      end

      direction.x, direction.y = 0, 0
      key_pressed = nil
  end
end

function love.update(dt)
  timer:update(dt)
end

function love.draw()
  for i = 1, map_size.x do
    for j = 1, map_size.y do
      if map[i][j] == 0 or map[i][j] >= 20 then
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


  -- View miscellaneous info
  love.graphics.print(
    string.format(
      (
        'Direction         : (%d, %d)\n' ..
        'Tile value        : %d\n' ..
        '#Pathway          : %d\n' ..
        'Player coordinates: (%d, %d)'
      ), 
      direction.x, 
      direction.y, 
      map[player.x][player.y], 
      #pathway, 
      player.x,
      player.y
    ), 
    30, 30 -- print location
  )


  -- -- View map as numbers
  -- for i = 1, map_size.x do
  --   for j = 1, map_size.y do
  --     love.graphics.print(map[i][j], dim/2 + (i-1) * dim - 5, dim/2 + (j-1) * dim - 5)
  --   end
  -- end

end

function love.keypressed(key)
  if key == 'r' then
    reset_map()
  elseif key == 'n' then
    -- coroutine.resume(paint_region)
    -- coroutine.resume(fill_smaller_area)
  end
end