local jua = require("jua")
local w = require("w")

w.init(jua)

local ws
local timePassed = 0

jua.on("terminate", function()
  print("Terminated")
  if ws then ws.close() end
  jua.stop()
end)

jua.on("mouse_click", function(event, button, x, y)
  print("Mouse Click at X: "..x.." Y: "..y)
end)

jua.go(function()
  w.open({
    success = function(url, handle)
      ws = handle
      print("Successfully connected.")
      ws.send("Hello world!")

      jua.setInterval(function()
        timePassed = timePassed + 1
        ws.send(timePassed.." seconds have passed.")
      end, 1)

      jua.setTimeout(function()
        print("The program ran for 15 seconds. Exiting...")
        ws.close()
        jua.stop()
      end, 15)
    end,
    
    failure = function(url)
      print("Failed to connect.")
      jua.stop()
    end,
    
    message = function(url, data)
      print("Message: "..data)
    end,
    
    closed = function(url)
      print("Connection closed")
      jua.stop()
    end
  }, "ws://echo.websocket.org")
end)