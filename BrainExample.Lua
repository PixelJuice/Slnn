local Slnn = require("network.Slnn")
math.randomseed(os.time())
local network = Slnn.New(2,1,1,3,0.05)
local result = {}

function Train(i1,i2,o)
  local inputs = {}
  local outputs = {}
  table.insert(inputs, i1)
  table.insert(inputs, i2)
  table.insert(outputs, o)
  return (network.Train(inputs,outputs))
end

function Calc(i1,i2)
  local inputs = {}
  table.insert(inputs, i1)
  table.insert(inputs, i2)
  return (network.CalcOutput(inputs))
end

for i=1,10000 do
  sumSquareError = 0
  result = Train(1, 1, 0)
  sumSquareError = sumSquareError + math.pow(result[1] - 0,2)
  result = Train(1, 0, 1)
  sumSquareError = sumSquareError + math.pow(result[1] - 1,2)
  result = Train(0, 1, 1)
  sumSquareError = sumSquareError + math.pow(result[1] - 1,2)
  result = Train(0, 0, 0)
  sumSquareError = sumSquareError + math.pow(result[1] - 0,2)
end

print("SSE: " .. sumSquareError)

result = Calc(1, 1)
print(" 1 1 " .. result[1])
result = Calc(1, 0)
print(" 1 0 " .. result[1])
result = Calc(0, 1)
print(" 0 1 " .. result[1])
result = Calc(0, 0)
print(" 0 0 " .. result[1])
