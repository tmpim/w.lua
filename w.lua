local jua = nil
local idPatt = "#R%d+"

if not http.websocketAsync then
  error("You do not have CC:Tweaked installed or you are not on the latest version.")
end

callbackRegistry = {}

local function gfind(str, patt)
  local t = {}
  for found in str:gmatch(patt) do
    table.insert(t, found)
  end

  if #t > 0 then
    return t
  else
    return nil
  end
end

local function findID(url)
  local found = gfind(url, idPatt)
  return tonumber(found[#found]:sub(found[#found]:find("%d+")))
end

local function newID()
  return #callbackRegistry + 1
end

local function trimID(url)
  local found = gfind(url, idPatt)
  local s, e = url:find(found[#found])
  return url:sub(1, s-1)
end

function open(callback, url, headers)
  local id = newID()
  local newUrl = url .. "#R" .. id
  http.websocketAsync(newUrl, headers)
  callbackRegistry[id] = callback
end

function init(jua)
  jua = jua
  jua.on("websocket_success", function(event, url, handle)
    local id = findID(url)
    if callbackRegistry[id].success then
      callbackRegistry[id].success(trimID(url), handle)
    end
  end)

  jua.on("websocket_failure", function(event, url)
    local id = findID(url)
    if callbackRegistry[id].failure then
      callbackRegistry[id].failure(trimID(url))
    end
    table.remove(callbackRegistry, id)
  end)

  jua.on("websocket_message", function(event, url, data)
    local id = findID(url)
    if callbackRegistry[id].message then
      callbackRegistry[id].message(trimID(url), data)
    end
  end)

  jua.on("websocket_closed", function(event, url)
    local id = findID(url)
    if callbackRegistry[id].closed then
      callbackRegistry[id].closed(trimID(url))
    end
    table.remove(callbackRegistry, id)
  end)
end

return {
  open = open,
  init = init
}
