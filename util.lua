function updateGroup(group, dt)
	for i = #group, 1, -1 do
		if group[i]:update(dt) or group[i].deleteMe then
			table.remove(group, i)
		end
	end
end

function print_r (t, name, indent) -- Credits to http://www.hpelbers.org/lua/print_r
    local tableList = {}
    function table_r (t, name, indent, full)
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

function inTable(t, needle)
	for i, v in pairs(t) do
		if v == needle then
			return i
		end
	end
	return false
end

function polygonarea(coords) --calculates the area of a polygon
	--Also written by Adam (see below)
	local anchorX = coords[1]
	local anchorY = coords[2]

	local firstX = coords[3]
	local firstY = coords[4]

	local area = 0

	for i = 5, #coords - 1, 2 do
		local x = coords[i]
		local y = coords[i + 1]

		area = area + (math.abs(anchorX * firstY + firstX * y + x * anchorY
				- anchorX * y - firstX * anchorY - x * firstY) / 2)

		firstX = x
		firstY = y

	end
	return area
end

function largeenough(coords) --checks if a polygon is good enough for box2d's snobby standards.
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

		if (projection < 0.04*METER) then

			return false

		end

	end

	return true

end

function drawLinedPolygon(points)
	for i = 1, #points-2, 2 do
		love.graphics.line(points[i], points[i+1], points[i+2], points[i+3])
	end
	love.graphics.line(points[#points-1], points[#points], points[1], points[2])
end

function findPointInShapes(shapes, x, y, notShape)
	for i = 1, #shapes do
		if i ~= notShape then
			local shape = shapes[i]

			for j = 1, #shape, 2 do
				local sx = shape[j]
				local sy = shape[j+1]

				if x == sx and y == sy then
					return i, j
				end
			end
		end
	end

	return false
end

function combineShapes(shapes)
	local newShapes = {}


	while #shapes > 0 do
		local newShape = {}
		local pointsToGo = shapes[1]

		while #pointsToGo > 0 do
			local x = pointsToGo[1]
			local y = pointsToGo[2]

			local foundShapeIndex, foundPointIndex = findPointInShapes(shapes, x, y, 1)

			if foundShapeIndex then --Point exists in another shape
				-- insert points into pointsToGo
				for i = foundPointIndex+2, #shapes[foundShapeIndex], 2 do
					local x = shapes[foundShapeIndex][i]
					local y = shapes[foundShapeIndex][i+1]

					table.insert(pointsToGo, x)
					table.insert(pointsToGo, y)
				end

				for i = 1, foundPointIndex-2, 2 do
					local x = shapes[foundShapeIndex][i]
					local y = shapes[foundShapeIndex][i+1]

					table.insert(pointsToGo, x)
					table.insert(pointsToGo, y)
				end

				table.remove(shapes, foundShapeIndex)
			else
				-- insert point into new shape
				table.insert(newShape, x)
				table.insert(newShape, y)
			end

			-- remove point from "to be processed"
			table.remove(pointsToGo, 1)
			table.remove(pointsToGo, 1)
		end

		-- next shape
		table.remove(shapes, 1)
		table.insert(newShapes, newShape)
		newShape = {}
	end

	return newShapes
end
