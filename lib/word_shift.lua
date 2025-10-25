local utf8 = require("utf8")

local function randomSymbol()
	return utf8.char(math.floor(math.random() * 50) + 192)
end

local wordCycler = {}

function wordCycler.wordCycle(list, noBuffer)
	local len = #list
	local tick = math.floor(os.clock() * 4) % (len * 5)
	local mod5 = ((os.clock() * 4) % (len * 5)) % 5
	local largeTick = math.floor(tick / 5) + 1
	local v = list[largeTick]

	if mod5 < 0.6 then
		v = wordCycler.blendWords(list[(largeTick - 2 + #list) % #list + 1], list[largeTick], (mod5 + 0.6) / 1.2)
	elseif mod5 > 4.4 then
		v = wordCycler.blendWords(list[largeTick], list[(largeTick % #list) + 1], (mod5 - 4.4) / 1.2)
	end

	v = wordCycler.randomCrossWords(v, 0.1 * math.pow(mod5 - 2.5, 4) - 0.6)
	if noBuffer then return v end

	local maxWordLen = 0
	for _, word in ipairs(list) do
		maxWordLen = math.max(maxWordLen, #word)
	end
	local bufferSpace = (maxWordLen - #v) / 2

	return string.rep(" ", math.ceil(bufferSpace)) .. v .. string.rep(" ", math.floor(bufferSpace))
end

function wordCycler.randomCrossWords(str, frac)
	if frac <= 0 then return str end
	local x = {}
	for i = 1, #str do
		x[i] = str:sub(i, i)
	end
	for i = 1, #x * frac do
		local randomIndex = math.random(#x) --math.floor(predictableRandom(math.floor(os.clock() * 2) % 964372 + 1.618 * i) * #x) + 1
		x[randomIndex] = randomSymbol()
	end
	return table.concat(x)
end

function wordCycler.blendWords(first, second, param)
	if param <= 0 then return first end
	if param >= 1 then return second end
	local part1 = first:sub(1, math.floor(#first * (1 - param)))
	local part2 = second:sub(math.floor(#second * (1 - param)) + 1, #second)
	return part1 .. part2
end

return wordCycler
