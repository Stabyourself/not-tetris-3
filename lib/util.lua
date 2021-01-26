local util = {}

function util.updateGroup(group, dt)
	for i = #group, 1, -1 do
		if group[i]:update(dt) or group[i].deleteMe then
			table.remove(group, i)
		end
	end
end

function util.print_r (t, name, indent) -- Credits to http://www.hpelbers.org/lua/print_r
    local tableList = {}
    local function table_r (t, name, indent, full)
      local id = not full and name
          or type(name)~="number" and tostring(name) or '['..name..']'
      local tag = indent .. id .. ' = '
      local out = {}	-- result
      if type(t) == "table" then
        if tableList[t] ~= nil then table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
        elseif t.isInstanceOf and indent ~= '' then table.insert(out, tag .. tostring(t))
        else
          tableList[t]= full and (full .. '.' .. id) or id
          if next(t) then -- Table not empty
            table.insert(out, tag .. '{')
            for key,value in pairs(t) do
              table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
            end
            table.insert(out,indent .. '}')
          else table.insert(out,tag .. '{}') end
        end
      else
        local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
        table.insert(out, tag .. val)
      end
      return table.concat(out, '\n')
    end
    print(table_r(t,name or 'Value',indent or ''))
end

function util.polygonArea(coords) --calculates the area of a polygon
	--Also written by Adam (see below)
	local anchorX = coords[1]
	local anchorY = coords[2]

	local firstX = coords[3]
	local firstY = coords[4]

	local area = 0

	for i = 5, #coords, 2 do
		local x = coords[i]
		local y = coords[i + 1]

		area = area + (math.abs(anchorX * firstY + firstX * y + x * anchorY
				- anchorX * y - firstX * anchorY - x * firstY) / 2)

		firstX = x
		firstY = y

	end
	return area
end

function util.largeEnough(coords) --checks if a polygon is good enough for box2d's snobby standards.
	--Written by Adam/earthHunter

	-- Calculation of centroids of each triangle

	local centroids = {}

	local anchorX = coords[1]
	local anchorY = coords[2]

	local firstX = coords[3]
	local firstY = coords[4]

	for i = 5, #coords - 1, 2 do

		local x = coords[i]
		local y = coords[i + 1]

		local centroidX = (anchorX + firstX + x) / 3
		local centroidY = (anchorY + firstY + y) / 3

		local area = math.abs(anchorX * firstY + firstX * y + x * anchorY
				- anchorX * y - firstX * anchorY - x * firstY) / 2

		local index = 3 * (i - 3) / 2 - 2

		centroids[index] = area
		centroids[index + 1] = centroidX * area
		centroids[index + 2] = centroidY * area

		firstX = x
		firstY = y

	end

	-- Calculation of polygon's centroid

	local totalArea = 0
	local centroidX = 0
	local centroidY = 0

	for i = 1, #centroids - 2, 3 do

		totalArea = totalArea + centroids[i]
		centroidX = centroidX + centroids[i + 1]
		centroidY = centroidY + centroids[i + 2]

	end

	centroidX = centroidX / totalArea
	centroidY = centroidY / totalArea

	-- Calculation of normals

	local normals = {}

	for i = 1, #coords - 1, 2 do

		local i2 = i + 2

		if (i2 > #coords) then

			i2 = 1

		end

		local tangentX = coords[i2] - coords[i]
		local tangentY = coords[i2 + 1] - coords[i + 1]
		local tangentLen = math.sqrt(tangentX * tangentX + tangentY * tangentY)

		tangentX = tangentX / tangentLen
		tangentY = tangentY / tangentLen

		normals[i] = tangentY
		normals[i + 1] = -tangentX

	end

	-- Projection of vertices in the normal directions
	-- in order to obtain the distance from the centroid
	-- to each side

	-- If a side is too close, the polygon will crash the game
  for i = 1, #coords - 1, 2 do

		local projection = (coords[i] - centroidX) * normals[i]
				+ (coords[i + 1] - centroidY) * normals[i + 1]

		if (projection < 0.02*METER) then -- can go as low as 0.001

			return false

		end

	end

	return true

end

function util.drawLinedPolygon(points)
	for i = 1, #points-2, 2 do
		love.graphics.line(points[i], points[i+1], points[i+2], points[i+3])
	end
	love.graphics.line(points[#points-1], points[#points], points[1], points[2])
end

function util.findPointInShapes(shapes, x, y, notShape, accuracy)
	for i = 1, #shapes do
		if i ~= notShape then
			local shape = shapes[i]

			for j = 1, #shape, 2 do
				local sx = shape[j]
				local sy = shape[j+1]

				if math.floatEqual(x, sx, accuracy) and math.floatEqual(y, sy, accuracy) then
					return i, j
				end
			end
		end
	end

	return false
end

function util.combineShapes(shapes)
	local newShapes = {}
	local newShape = {}

	for i, shape in ipairs(shapes) do
		if not shape.traversed then
			-- find first point that isn't shared
			local shapeI = i

			local firstPointI = 1
			local firstShapeI = shapeI

			while util.findPointInShapes(shapes, shape[firstPointI], shape[firstPointI+1], shapeI) do
				firstPointI = firstPointI+2
			end
			local pointI = firstPointI


			repeat -- loop through points until we made a neat circle
				pointI = pointI + 2

				if pointI > #shapes[shapeI] then --loop points
					pointI = 1
				end

				local foundShapeI, foundPointI = util.findPointInShapes(shapes, shapes[shapeI][pointI], shapes[shapeI][pointI+1], shapeI)

				if foundShapeI then -- traversal point
					shapeI = foundShapeI
					pointI = foundPointI+2

					if pointI > #shapes[shapeI] then --loop points
						pointI = 1
					end

					shapes[shapeI].traversed = true
				end

				table.insert(newShape, shapes[shapeI][pointI])
				table.insert(newShape, shapes[shapeI][pointI+1])

			until shapeI == firstShapeI and pointI == firstPointI

			table.insert(newShapes, newShape)
			newShape = {}
		end
	end

	-- clean up after ourselves
	for _, shape in ipairs(shapes) do
		shape.traversed = nil
	end

	return newShapes
end

function util.iclearTable(t)
	for i = #t, 1, -1 do
		t[i] = nil
	end
end

function util.clearTable(t)
	for i in pairs(t) do
		t[i] = nil
	end
end

function util.setPointTable(t, x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8) -- this is good code, I promise
	t[1] = x1
	t[2] = y1
	t[3] = x2
	t[4] = y2
	t[5] = x3
	t[6] = y3
	t[7] = x4
	t[8] = y4
	t[9] = x5
	t[10] = y5
	t[11] = x6
	t[12] = y6
	t[13] = x7
	t[14] = y7
	t[15] = x8
	t[16] = y8
end

function table.includesI(t, needle)
	for i = #t, 1, -1 do
		if t[i] == needle then
			return i
		end
	end
	return false
end

function math.sign(a)
	if a < 0 then
		return -1
	elseif a > 0 then
		return 1
	else
		return 0
	end
end

function math.floatEqual(a, b, accuracy)
	return math.abs(a-b) < 1/10^(accuracy or 8)
end

function math.round(a)
	return math.floor(a+.5)
end

function util.distance(x1, y1, x2, y2)
	return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
end

return util
