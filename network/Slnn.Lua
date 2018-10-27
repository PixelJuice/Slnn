function Neuron(nInputs)
  local o = {}
  o.numInputs = nInputs
  local weightRange = 2.4/nInputs
  o.bias = math.random() * (weightRange - -weightRange) + -weightRange
  o.output = 0
  o.errorGradient = 0
  o.weights = {}
  for i=1, nInputs do
    table.insert(o.weights, math.random() * (weightRange - -weightRange) + -weightRange)
  end
  o.inputs = {}
  return o
end

function Layer(nNeurons, nNeuronsInputs)
  local o = {}
  o.numNeurons = nNeurons
  o.neurons = {}
  for i=1, o.numNeurons do
    table.insert(o.neurons, Neuron(nNeuronsInputs))
  end
  return o
end

function TanH(value)
  local k = math.exp(-2*value)
  return 2 / (1 + k) - 1
end

function Sigmoid(value)
  local k = math.exp(value)
  return k / (1 + k)
end

function LeakyReLu(value)
	if(value < 0) then
    return 0.01*value
  else
   	return value
  end
end

local Slnn = {}
function Slnn.New(nI, nO, nH, nPH, a)
  local o = {}
  o.numInputs = nI
  o.numOutputs = nO
  o.numHidden = nH
  o.numNPerHidden = nPH
  o.alpha = a
  o.layers = {}
  if o.numHidden > 0 then
    table.insert(o.layers, Layer(o.numNPerHidden, o.numInputs))
    for i=2, o.numHidden do
      table.insert(o.layers, Layer(o.numNPerHidden, o.numNPerHidden))
    end
    table.insert(o.layers, Layer(o.numOutputs, o.numNPerHidden))
  else
    table.insert(o.layers, Layer(o.numOutputs, o.numInputs))
  end

  function o.Train(inputValues, desiredOutput)
    local outputValues = o.CalcOutput(inputValues)
    o.UpdateWeights(outputValues, desiredOutput)
    return outputValues
  end

  function o.CalcOutput(inputValues)
    local inputs = {}
    local outputValues = {}
    local currentInput = 1
    --print(#inputValues)
    if #inputValues ~= o.numInputs then
      print("Error: Number of inputs should be" .. o.numInputs)
      return outputValues
    end

    local inputs = inputValues
    for i=1, o.numHidden+1 do
        if i > 1 then
          inputs = outputValues
        end
        outputValues = {}
        for j=1, o.layers[i].numNeurons do
          N = 0
          o.layers[i].neurons[j].inputs = {}
          for k=1,o.layers[i].neurons[j].numInputs do
            table.insert(o.layers[i].neurons[j].inputs, inputs[currentInput])
            N = N + o.layers[i].neurons[j].weights[k] * inputs[currentInput]
            currentInput = currentInput +1
          end
          N = N -o.layers[i].neurons[j].bias
          if i == #o.layers then
            o.layers[i].neurons[j].output = Sigmoid(N)
          else
            o.layers[i].neurons[j].output = TanH(N)
          end
          table.insert(outputValues, o.layers[i].neurons[j].output)
          currentInput = 1
        end
    end
    return outputValues
  end

  function o.PrintWeights()
    local weightStr = ""
    for k,l in pairs(o.layers) do
      for k,n in pairs(l.neurons) do
        for k,w in pairs(n.weights) do
          weightStr = weightStr .. w .. ","
        end
        weightStr = weightStr .. n.bias .. ","
      end
    end
    return weightStr
  end

  function o:LoadWeights(weightStr)
    if weightStr == "" then
      return
    end
    local weightValues = {}
    for value in string.gmatch(weightStr, '([^,]+)') do
      table.insert(weightValues, value)
    end
    w = 1
    for k,l in pairs(o.layers) do
      for k,n in pairs(l.neurons) do
        for i = 1, #n.weights do
          n.weights[i] = weightValues[w]
          w = w +1
        end
        n.bias = weightValues[w]
        w = w +1
      end
    end
  end

  function o.UpdateWeights(outputs, desiredOutput)
    local error = 0
    for i = #o.layers, 1,-1 do
      for j=1,o.layers[i].numNeurons do
        if i == #o.layers then
          error = desiredOutput[j] - outputs[j]
          o.layers[i].neurons[j].errorGradient = outputs[j] * (1-outputs[j]) * error
        else
          o.layers[i].neurons[j].errorGradient = o.layers[i].neurons[j].output * (1-o.layers[i].neurons[j].output)
          local errorGradSum = 0
          for p=1, o.layers[i+1].numNeurons do
            errorGradSum = errorGradSum + o.layers[i+1].neurons[p].errorGradient * o.layers[i+1].neurons[p].weights[j]
          end
          o.layers[i].neurons[j].errorGradient = o.layers[i].neurons[j].errorGradient * errorGradSum
        end
        for k=1,o.layers[i].neurons[j].numInputs do
          if i == #o.layers then
            error = desiredOutput[j] - outputs[j]
            o.layers[i].neurons[j].weights[k] = o.layers[i].neurons[j].weights[k] + o.alpha * o.layers[i].neurons[j].inputs[k] * error
          else
            o.layers[i].neurons[j].weights[k] = o.layers[i].neurons[j].weights[k] + o.alpha * o.layers[i].neurons[j].inputs[k] * o.layers[i].neurons[j].errorGradient
          end
        end
        o.layers[i].neurons[j].bias = o.layers[i].neurons[j].bias + o.alpha * -1 * o.layers[i].neurons[j].errorGradient
      end
    end
  end

  function o.OutputActivationFunction(value)
    return Sigmoid(value)
  end

  function o.HiddenActivationFunction(value)
    return LeakyReLu(value)
  end

return o
end

return Slnn
