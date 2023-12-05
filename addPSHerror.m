function [hFill, err] = addPSHerror (t, freq, stdErr, color)
hold on
[nRow, nCol] = size(t);
if nRow < nCol
    t=t';
end
tt = [t; flip(t)];
[nRow, nCol] = size(freq);
if nRow < nCol
    freq = freq';
end
[nRow, nCol] = size(stdErr);
if nRow < nCol
    stdErr = stdErr';
end

topErr = freq + stdErr;
bottomErr =  freq - stdErr;

err = [topErr; flip(bottomErr)];
hFill = fill (tt, err, color, 'FaceAlpha', 0.4, 'LineStyle', 'none', 'Marker', 'none');
hold off

end