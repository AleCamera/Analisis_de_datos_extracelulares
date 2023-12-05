function newColor = getDifferentRGB (oldColor)
oldR  = oldColor(1);
oldB = oldColor(3);
topBrightness = 0.85;
halfBrightness = topBrightness/2;
if oldR > oldB
    B = halfBrightness + halfBrightness*rand;
    R = halfBrightness * rand;
else
    R = halfBrightness + halfBrightness*rand;
    B = halfBrightness * rand;
end
G = topBrightness*rand;
if R < 0
    R = 0.1 * rand;
end
if G < 0
    G = 0.1 * rand;
end
if B < 0
    B = 0.1*rand;
end

newColor = [R G B];