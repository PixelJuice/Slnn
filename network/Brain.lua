function Memory(r, s)
  local o = {}
  o.reward = r
  o.states = s
  return o
end

function Clamp( _in, low, high)
  return math.min( math.max( _in, low ), high )
end

function SoftMax(list)
  local max = math.max(unpack(list))
  local scale = 0.0
  for i=1,#list do
    scale = scale + math.exp(list[i] - max)
  end
  result = {}
  for i=1,#list do
    table.insert(result, math.exp((list[i] - max)) / scale)
  end
  return result
end

local function indexSort(tbl)
  local idx = {}
  for i = 1, #tbl do idx[i] = i end
  table.sort(idx, function(a, b) return tbl[a] > tbl[b] end)
  return (table.unpack or unpack)(idx)
end

local Brain = {}
function Brain.New()
  o = {}
  o.inputs = {}
  o.outputs = {}
  o.network = {}
  o.memories = {}
  o.mCapacity = 10000
  o.reward = 0
  o.discount = 0.99
  o.exploreRate = 100
  o.maxExploreRate = 100
  o.minExploreRate = 0.01
  o.exploreDecay = 0.0001

  function o.AddObservation(obv)
    table.insert(o.inputs, obv)
  end

  function o.ResetObservations()
    o.inputs = {}
  end

  function o.SetReward(reward)
    o.reward = o.reward + reward
  end

  function o.Train(outputs)
    return (o.network.Train(o.inputs,outputs))
  end

  function o.CaclutateAction()
    local qs = {}
    qs = SoftMax(o.network.CalcOutput(o.inputs))
    local maxQ = math.max(unpack(qs))
    maxQIndex = indexSort(qs)
    o.exploreRate = Clamp(o.exploreRate - o.exploreDecay, o.minExploreRate, o.maxExploreRate)
    if (math.random() * 100) < o.exploreRate then
      maxQIndex = math.random(1, #qs)
    end
    return maxQIndex
  end

  function o.TakeAction(action)
    --overwrite with actions
  end

  function o.calculateReward()
    --overwrite with rewards
  end

  function o.SaveMemory()
    local mem = Memory(o.reward, o.inputs)
    table.insert(o.memories, mem)
    if #o.memories > o.mCapacity then
      table.remove(o.memories)
    end
  end

  function o.UpdateWeights()
    for i=1, #o.memories do
      local outputOld = {}
      local outputNew = {}
      outputOld = SoftMax(o.network.CalcOutput(o.memories[i].states))
      local maxQOld = indexSort(outputOld)
      local action = outputOld[maxQOld]

      local feedback = {}
      if i == #o.memories then
        feedback = o.memories[i].reward
      else
        outputNew = SoftMax(o.network.CalcOutput(o.memories[i+1].states))
        local maxQ = indexSort(outputNew)
        feedback = (o.memories[i].reward + o.discount * maxQ)
      end

      outputOld[action] = feedback
      o.network.Train(o.memories[i].states, outputOld)
    end
  end

return o
end

return Brain
