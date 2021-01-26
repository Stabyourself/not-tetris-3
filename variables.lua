WIDTH = 256
HEIGHT = 224

SCALE = 3
BLOCKSCALE = 8

METER = 10
PHYSICSSCALE = 32
BLOCKSIZE = PHYSICSSCALE^2
LINECLEARREQUIREMENT = 0.8

LINECLEARTIME = 0.3

MOVEFORCE = 30000
ROTATEFORCE = 700000

MAXMOVESPEED = 10
MAXROTATESPEED = 10

PIECESTARTX = 5.125*PHYSICSSCALE
PIECESTARTY = -1*PHYSICSSCALE

WALLEXTEND = 1000

MAXSPEEDYBASE = 100
MAXSPEEDYPERLEVEL = 10
GRAVITY = 600

PIECEFRICTION = 0.6
WALLFRICTION = 0
FLOORFRICTION = PIECEFRICTION

WORLDUPDATEINTERVAL = 1/144

LINESUPDATEINTERVAL = 1/15
PUYOGROUPUPDATEINTERVAL = 1/15
PUYOCHAINTIME = 2

PUYODISTANCE = 65

DIAMONDADD = 0

DEBUG_DRAWSHAPES = false
DEBUG_DRAWSUBSHAPES = false
DEBUG_DRAWSUBSHAPEROWS = false
DEBUG_HIDEBLOCKS = false
DEBUG_DRAWSHAPEVERTICES = false
DEBUG_DRAWLINEAREA = false
DEBUG_PRINTQUEUEDGARBAGE = false

FIXEDRNG = true

LINECOLORS = {
    {0, 0, 0},
    {0.15, 0.15, 0.15},
}

GARBAGETABLE = {
    1,
    4,
    8,
    16,
    24,
}
GARBAGEWAITTIME = 0.6
GARBAGEWAITTIMEPERROW = 0.2
GARBAGECOUNT = 8

FLASHTIMEON = 1/60
FLASHTIMEOFF = 3/60

CRAZYFLASHYTIMERON = 3/60
CRAZYFLASHYTIMEROFF = 1/60

FIRSTPIECEWAITTIME = 1

COLORS = {
    levelSelectActive = {0.988, 0.596, 0.22},
    levelNumbers = {0.847, 0.157, 0}
}