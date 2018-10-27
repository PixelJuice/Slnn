local Controller = {}
function Controller.Draw()
  gui.drawRectangle(2,205,50,25,0xFFEEEEEE, 0xFF101010)
  if latestAction == 1 or latestAction == 3 then
    gui.drawEllipse(43,219,5,6,0xFFAA5050, 0xFFFF9090)
  else
    gui.drawEllipse(43,219,5,6,0xFFAA5050, 0xFFFF1010)
  end
  if latestAction == 2 or latestAction == 4 then
    gui.drawEllipse(35,219,5,6,0xFFAA5050, 0xFFFF9090)
  else
    gui.drawEllipse(35,219,5,6,0xFFAA5050, 0xFFFF1010)
  end
  gui.drawRectangle(20,219,12,6,0xFFEEEEEE, 0xFFEEEEEE)
  gui.drawRectangle(20,213,12,3,0xFF808080, 0xFF808080)
  gui.drawRectangle(20,207,12,3,0xFF808080, 0xFF808080)

  gui.drawRectangle(20,221,6,3,0xFFEEEEEE, 0xFF101010)
  if latestAction == 8 then
      gui.drawRectangle(26,221,6,3,0xFFEEEEEE, 0xFF909090)
    else
      gui.drawRectangle(26,221,6,3,0xFFEEEEEE, 0xFF101010)
  end

  gui.drawRectangle(4,215,12,6,0xFFEEEEEE, 0xFFEEEEEE)
  gui.drawRectangle(7,212,6,12,0xFFEEEEEE, 0xFFEEEEEE)
  gui.drawRectangle(8,217,4,4,0xFF101010, 0xFF101010)
  if latestAction == 3 or latestAction == 4 then
    gui.drawRectangle(8,213,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(8,213,4,4,0xFF101010, 0xFF101010)
  end
  if latestAction == 6 then
    gui.drawRectangle(11,216,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(11,216,4,4,0xFF101010, 0xFF101010)
  end
  if latestAction == 7 then
    gui.drawRectangle(8,219,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(8,219,4,4,0xFF101010, 0xFF101010)
  end
  if latestAction == 5 then
    gui.drawRectangle(5,216,4,4,0xFF101010, 0xFF909090)
  else
    gui.drawRectangle(5,216,4,4,0xFF101010, 0xFF101010)
  end
end

return Controller
