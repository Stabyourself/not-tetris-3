local Timer = CLASS("Timer")

local timers = {}

function Timer.setTimer(func, t)
	local timer = Timer:new(func, t)
	table.insert(timers, timer)

	return timer
end

function Timer.managedUpdate(dt)
	util.updateGroup(timers, dt)
end

function Timer:initialize(func, t)
	self.func = func
	self.t = t

	self.timer = 0
	self.running = true
end

function Timer:update(dt)
	if self.running then
		self.timer = self.timer + dt

		if self.timer >= self.t then
			self.timer = self.t

			if self.func then
				self.func()
			end

			return true
		end
	end
end

function Timer:getTimeLeft()
	return self.t - self.timer
end

return Timer

-- function Timer:easing(easingfunc, from, to, c, d)
-- 	return easingfunc(self.timer, from, to, self.t, c or self.t, d)
-- end
