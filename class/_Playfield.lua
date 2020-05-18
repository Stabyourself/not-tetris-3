local _Playfield = CLASS("_Playfield")

function _Playfield:initialize()
    self.queuedGarbage = 0
    self.spawnNewPieceNextFrame = false
end

function _Playfield:sendGarbage(count)
    if self.queuedGarbage < count then
        count = count - self.queuedGarbage
        self.queuedGarbage = 0
    else
        self.queuedGarbage = self.queuedGarbage - count
        count = 0
    end

    if count > 0 then
        self.game:sendGarbage(self, count)
    end
end

function _Playfield:receiveGarbage(count)
    self.queuedGarbage = self.queuedGarbage + count
end

function _Playfield:checkGarbageSpawn() -- todo: don't like this being part of _Playfield
    if self.queuedGarbage > 0 then -- oh no
        local garbageWaitTime = GARBAGEWAITTIME + GARBAGEWAITTIMEPERROW * self.queuedGarbage

        self:spawnGarbage(self.queuedGarbage)
        self.queuedGarbage = 0

        TIMER.setTimer(function() self.spawnNewPieceNextFrame = true end, garbageWaitTime)
    else
        self.spawnNewPieceNextFrame = true
    end
end

function _Playfield:spawnGarbage()
    error("_Playfield:spawnGarbage needs to be implemented.")
end

return _Playfield