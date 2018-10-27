local Controller = require("utils.Controller")
local Slnn = require("network.Slnn")
local Brain = require("network.Brain")

local marioX = 0
local marioY = 0
local viewDist = 6
local guiSize = 4
local guiOffsetX = 2
local guiOffsetY = 10
local inputs = {}
local buttons = {"A","B", "B+Left", "B+Right", "Left", "Right", "Down", "Nothing" }
local controller = {}

local network = Slnn.New(169,8,2,8,0.1)
local brain = Brain.New()
brain.network = network

brain.exploreRate = 99
brain.exploreDecay = 0.0001
brain.discount = 0.99
local distance = 0
local weightName = "SMB"
local stateName = "SMB.State"

function WriteFile(filename)
  local file = io.open(filename, "wb")
  file:write(brain.network.PrintWeights())
  file:close()
end

function ReadFile(filename)
  local file = io.open(filename, "wb")
  if file then
    local weights = file:read("*a")
    file:close()
    brain.network.LoadWeights(self,weights)
  end
end

function brain.TakeAction(action)
  controller = {}
  if action == 2 then
    controller["P1 " .. "A"] = true
  elseif action == 3 then
    controller["P1 " .. "B"] = true
  elseif action == 4 then
    controller["P1 " .. "B"] = true
    controller["P1 " .. "Left"] = true
  elseif action == 5 then
    controller["P1 " .. "B"] = true
    controller["P1 " .. "Right"] = true
  elseif action == 6 then
    controller["P1 " .. "Down"] = true
  elseif action == 7 then
    controller["P1 " .. "Left"] = true
  elseif action == 8 then
    controller["P1 " .. "Right"] = true
  end
  --print("Action: " .. buttons[action])
end

function brain.calculateReward()
  if marioX > distance then
    brain.SetReward(0.5)
    distance = marioX
  end
end

function GetPosition()
  marioX = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
  marioY = memory.readbyte(0x03B8) +16
  --gui.text(2, 225, "World posX: " .. marioX)
  --gui.text(2, 245, "World posY: " .. marioY)

  --gui.text(2, 265, "Screen posX: " .. memory.readbyte(0x03AD))
  --gui.text(2, 285, "Screen posY: " .. memory.readbyte(0x03B8))
end

function GetTile(dx,dy)
  local x = marioX + dx + 8
  local y = marioY + dy - 16
  local page = math.floor(x/256)%2

  local subx = math.floor((x%256)/16)
  local suby = math.floor((y - 32)/16)
  local addr = 0x500 + page*13*16+suby*16+subx

  if suby >= 13 or suby < 0 then
          return 0
  end

  if memory.readbyte(addr) ~= 0 then
          return 1
  else
          return 0
  end
end

function GetSprites()
  local sprites = {}
  for slot=0,4 do
    local enemy = memory.readbyte(0xF+slot)
    if enemy ~= 0 then
      local x = memory.readbyte(0x6E + slot)*0x100 + memory.readbyte(0x87+slot)
      local y = memory.readbyte(0xCF + slot)+24
      sprites[#sprites+1] = {["x"]=x,["y"]=y}
    end
  end
  return sprites
end

function GetInputs()
  inputs = {}
  local sprites = GetSprites()
  for y=-viewDist*16,viewDist*16,16 do
    for x=-viewDist*16,viewDist*16,16 do
      inputs[#inputs+1] = GetTile(x,y)
      for i = 1,#sprites do
        distx = math.abs(sprites[i]["x"] - (marioX+x))
        disty = math.abs(sprites[i]["y"] - (marioY+y))
        if distx <= viewDist and disty <= viewDist then
          inputs[#inputs] = -1
        end
      end
    end
  end
end

function DrawScreen()
  --print(#inputs)
  local sqr = math.sqrt(#inputs)
  for i = 0,#inputs-1 do
    --print(i%13)
    if inputs[i+1] == 1 then
      gui.drawRectangle(i%sqr*guiSize + guiOffsetX,math.floor(i/sqr)*guiSize + guiOffsetY,guiSize,guiSize,0xAAFFFFFF, 0xAAFFFFFF)
    elseif inputs[i+1] == -1 then
      gui.drawRectangle(i%sqr*guiSize + guiOffsetX,math.floor(i/sqr)*guiSize + guiOffsetY,guiSize,guiSize,0xAAFF0000, 0xAAFF0000)
    else
      gui.drawRectangle(i%sqr*guiSize + guiOffsetX,math.floor(i/sqr)*guiSize + guiOffsetY,guiSize,guiSize,0xAA101010, 0xAA101010)
    end
  end
end

function InitializeRun()
  savestate.load(stateName);
  print("ExploreRate: " .. brain.exploreRate)
  Loop()
end

function Loop()
  if mainmemory then
    while true do
      GetPosition()
      GetInputs()
      DrawScreen()
      brain.reward = 0
      brain.calculateReward()
      for i=1,#inputs do
        brain.AddObservation(inputs[i])
      end
      local action = brain.CaclutateAction()
      brain.TakeAction(action)
      joypad.set(controller)
      brain.SaveMemory()
      brain.ResetObservations()
      if mainmemory.read_u8(0x000E) == 11 then
        brain.UpdateWeights()
        brain.memories = {}
        WriteFile(weightName)
        InitializeRun()
      end
      emu.frameadvance()
    end
  end
end

ReadFile(weightName)
InitializeRun()
