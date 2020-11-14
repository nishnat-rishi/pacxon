local timer = {
  _timers = {},
}

function timer:create(params)
  params._curr = 0
  self._timers[params.id] = params
  
  if params.start_exhausted then
    params.is_running = false

  end

  return params
end

function timer:update(dt)
  for _, t in pairs(self._timers) do
    t._curr = t._curr + dt
    if t._curr >= t.period then
      t.callback()
      if t.periodic then
        t._curr = 0
      end
    end
  end
end

return timer