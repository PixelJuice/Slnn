local Slnn = require("../../Network.Slnn")
local Brain = require("../../Network.Brain")

local network = Slnn.New(7,9,2,8,0.05)
-- A, B, A+Up, B+Up, left, right, down, start, Nothing
local brain = Brain.New()
brain.network = network

brain.exploreRate = 99
brain.exploreDecay = 0.0001
brain.discount = 0.99

local controller = {}
local buttons = {"A","B", "A+Up", "B+Up", "Left", "Right", "Down", "Start", "Nothing" }
local hearts = {}
local opponentHealth = {}
local playerHealth = {}
local starHits = {}
local actionTimer = 0
local actionID = 0
local dangerTimer = 0
local frame = 0
local weightName = "punchWeights7"
local latestAction = 0
local ShowAction = 0
--local dodge = 0
local punching = 0
local doingAction = false
local actionDecided = false
local hasDodged = 0

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
    controller["P1 " .. "A"] = true
    controller["P1 " .. "Up"] = true
  elseif action == 5 then
    controller["P1 " .. "B"] = true
    controller["P1 " .. "Up"] = true
  elseif action == 6 then
    controller["P1 " .. "Start"] = true
  elseif action == 7 then
    controller["P1 " .. "Down"] = true
  elseif action == 8 then
    controller["P1 " .. "Left"] = true
  elseif action == 9 then
    controller["P1 " .. "Right"] = true
  end
  --print("Action: " .. buttons[action])
end

function brain.calculateReward()
  local newHearts = (mainmemory.read_u8(0x0323) * 10) + mainmemory.read_u8(0x0324)
  local newOpponentHealth = mainmemory.read_u8(0x0399)
  local newPlayerHealth = mainmemory.read_u8(0x0392)
  local newStarHits = mainmemory.read_u8(0x0342)
  brain.SetReward(-0.001)
  if newHearts < hearts then
    brain.SetReward(-0.4)
  end
  if newOpponentHealth < opponentHealth then
    brain.SetReward(0.5)
  end
  if newPlayerHealth < playerHealth then
    brain.SetReward(-0.5)
  end
  if newStarHits > starHits then
    brain.SetReward(0.1)
  end
  if latestAction == 9 then
    brain.SetReward(0.3)
  end
  if mainmemory.read_u8(0x0005) == 2 then
    brain.SetReward(-10.0)
  end
  if mainmemory.read_u8(0x0328) > 0 then
    brain.SetReward(-8.0)
  end
  hearts = newHearts
  opponentHealth = newOpponentHealth
  playerHealth = newPlayerHealth
  starHits = newStarHits
  --print("reward " .. brain.reward)
end

if gameinfo.getromname() == "Mike Tyson's Punch-Out!!" then
        Filename = "PO2.state"
				console.log("It is Punch Out")
end

function drawUI()

  gui.text(2, 240, "Dodged: " .. hasDodged)
  gui.text(2, 180, "Opp Timer: " .. dangerTimer)
  gui.text(2, 195, "Opp Action: " .. ShowAction)
  local o = 0
  if doingAction then
    o = 1
  end
  gui.text(2, 210, "doing something: " .. o)
  local o2 = 0
  if actionDecided then
    o2 = 1
  end
  gui.text(2, 225, "Action: " .. o2)
  gui.drawRectangle(2,190,50,25,0xFFEEEEEE, 0xFF101010)
  if latestAction == 1 or latestAction == 3 then
    gui.drawEllipse(43,204,5,6,0xFFAA5050, 0xFFFF9090)
  else
    gui.drawEllipse(43,204,5,6,0xFFAA5050, 0xFFFF1010)
  end
  if latestAction == 2 or latestAction == 4 then
    gui.drawEllipse(35,204,5,6,0xFFAA5050, 0xFFFF9090)
  else
    gui.drawEllipse(35,204,5,6,0xFFAA5050, 0xFFFF1010)
  end
  gui.drawRectangle(20,204,12,6,0xFFEEEEEE, 0xFFEEEEEE)
  gui.drawRectangle(20,198,12,3,0xFF808080, 0xFF808080)
  gui.drawRectangle(20,192,12,3,0xFF808080, 0xFF808080)

  gui.drawRectangle(20,206,6,3,0xFFEEEEEE, 0xFF101010)
  if latestAction == 8 then
      gui.drawRectangle(26,206,6,3,0xFFEEEEEE, 0xFF909090)
    else
      gui.drawRectangle(26,206,6,3,0xFFEEEEEE, 0xFF101010)
  end

  gui.drawRectangle(4,200,12,6,0xFFEEEEEE, 0xFFEEEEEE)
  gui.drawRectangle(7,197,6,12,0xFFEEEEEE, 0xFFEEEEEE)
  gui.drawRectangle(8,202,4,4,0xFF101010, 0xFF101010)
  if latestAction == 3 or latestAction == 4 then
    gui.drawRectangle(8,198,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(8,198,4,4,0xFF101010, 0xFF101010)
  end
  if latestAction == 6 then
    gui.drawRectangle(11,201,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(11,201,4,4,0xFF101010, 0xFF101010)
  end
  if latestAction == 7 then
    gui.drawRectangle(8,204,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(8,204,4,4,0xFF101010, 0xFF101010)
  end
  if latestAction == 5 then
    gui.drawRectangle(5,201,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(5,201,4,4,0xFF101010, 0xFF101010)
  end
end

function loop()
  if mainmemory then
    while true do

      if frame % 4 == 0 then
        controller = {}
      end

      if mainmemory.read_u8(0x0000) ~= 1 then
        if frame % 10 == 0 then
          brain.TakeAction(6)
          joypad.set(controller)
        end
      end

      frame = frame + 1
      if frame > 9999 then
        frame = 0
      end

      punching = mainmemory.read_u8(0x0097)
      if mainmemory.read_u8(0x003A) ~= actionID then
        dangerTimer = 0
        actionID = mainmemory.read_u8(0x003A)
      end
      if mainmemory.read_u8(0x0039) == actionTimer and punching == 1 then
        dangerTimer = dangerTimer + 1
        ShowAction = actionID
      else
        dangerTimer = 0
        ShowAction = 0
      end
      actionTimer = mainmemory.read_u8(0x0039)
      local pos = mainmemory.read_u8(0x0015)
      if actionDecided then
        if pos > 182 or pos < 170 then
          doingAction = true
          actionDecided = false
        else
          doingAction = false
        end
      elseif pos == 176 then
        doingAction = false
      end

      -- frame % 6 == 0
      if not actionDecided and not doingAction or frame % 6 == 0 and actionDecided and not doingAction then
        if mainmemory.read_u8(0x0000) == 1 then
          local matchState = mainmemory.read_u8(0x0005)
          if matchState == 0 then
            brain.reward = 0
            brain.calculateReward()
          --  if mainmemory.read_u8(0x0015) ~= 176 then
            --  dodge = 1
          --  else
              --dodge = 0
          --end
            --brain.AddObservation(dodge) -- is dodgeing
            brain.AddObservation(punching) -- opp is punching
            brain.AddObservation(latestAction) -- Last Input
            --brain.AddObservation(matchState) -- matchState
            brain.AddObservation(mainmemory.read_u8(0x0001)) -- opponent ID
            brain.AddObservation(dangerTimer) -- Opponent Action Timer
            --print("dangerTimer " .. dangerTimer)
            brain.AddObservation(ShowAction)
            -- brain.AddObservation(opponentHealth) -- Opponent Health
            brain.AddObservation(starHits)          -- Star Hits
            --brain.AddObservation(hearts)            -- Mac's Hearts
            --brain.AddObservation(mainmemory.read_u8(0x02B8)) -- Opponent Pos
            --brain.AddObservation(mainmemory.read_u8(0x004A)) -- Inv Frames
            hasDodged = 0
            if ShowAction ~= 0 and latestAction > 7  then
              hasDodged = 1
            end
            brain.AddObservation(starHits)
            latestAction = brain.CaclutateAction()
            actionDecided = true
            brain.TakeAction(latestAction)
            joypad.set(controller)
            frame = 0
            brain.SaveMemory()
            brain.ResetObservations()
          end
          if mainmemory.read_u8(0x0328) > 0 then
            brain.UpdateWeights()
            brain.memories = {}
            WriteFile(weightName)
            initializeRun()
          elseif matchState == 2 then
            brain.UpdateWeights()
            brain.memories = {}
            WriteFile(weightName)
            initializeRun()
          end
        end
      end

      drawUI()
      emu.frameadvance()
    end
  end
end

function initializeRun()
        savestate.load(Filename);
        hearts = (mainmemory.read_u8(0x0323) * 10) + mainmemory.read_u8(0x0324)
        opponentHealth = mainmemory.read_u8(0x0399)
        playerHealth = mainmemory.read_u8(0x0392)
        starHits = mainmemory.read_u8(0x0342)
        actionTimer = mainmemory.read_u8(0x0039)
        print("ExploreRate: " .. brain.exploreRate)
        loop()
end

ReadFile(weightName)
initializeRun()
