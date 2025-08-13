classdef MiceData
    properties
        nStims;
        stimCode;
        trial;
        ballDiameter;
        crabID;
    end
    
    methods
        function obj = MiceData(data, time, stimStart, stimFinish, nStims, diameter, crabID)
            obj.nStims = nStims;
            obj.ballDiameter = diameter;
            obj.crabID = crabID;
            for n = 1:nStims
                ind = time > stimStart(n) & time < stimFinish(n);
                obj.trial(n).time = time(ind) - stimStart(n);
                obj.trial(n).offset = stimStart(n);
                obj.trial(n).duration = stimFinish(n) - stimStart(n);
                X1 = data(ind, 1);
                Y1 = data(ind, 2);
                X2 = data(ind, 3);
                Y2 = data(ind, 4);
                obj.trial(n).vX1 = X1(2:end) ./ diff(obj.trial(n).time);
                obj.trial(n).vY1 = Y1(2:end) ./ diff(obj.trial(n).time);
                obj.trial(n).vX2 = X2(2:end) ./ diff(obj.trial(n).time);
                obj.trial(n).vY2 = Y2(2:end) ./ diff(obj.trial(n).time);
                obj.trial(n).time = obj.trial(n).time(2:end);
            end
        end
        function intpRuns = interpolateRuns(obj, runs, dt, varargin)
            % takes a trial number (runs) and a binsize in seconds (dt) and
            % returns an struct with the time, traslational and roational
            % velocitys and direction.
            
            useSmooth = false;
            span = 5;
            method = 'moving'; 
            
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'smooth'
                        useSmooth = varargin{arg+1};
                    case 'span'
                        span = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                    otherwise
                        error(['invalid optional argument: ' varargin{arg}])
                end
            end
            for nr = 1:length(runs)
                r = runs(nr);
                newTime = 0:dt:obj.trial(r).duration;
                if isempty(obj.trial(r).time) || length(obj.trial(r).time) == 1
                    intpRuns(nr).time = newTime;
                    intpRuns(nr).vTras = zeros(size(newTime));
                    intpRuns(nr).vRot = zeros(size(newTime));
                    intpRuns(nr).dir = zeros(size(newTime));
                    intpRuns(nr).vX1 = zeros(size(newTime));
                    intpRuns(nr).vX2 = zeros(size(newTime));
                else
                    vX1 = interp1(obj.trial(r).time, obj.trial(r).vX1, newTime);
                    vY1 = interp1(obj.trial(r).time, obj.trial(r).vY1, newTime);
                    vX2 = interp1(obj.trial(r).time, obj.trial(r).vX2, newTime);
                    vY2 = interp1(obj.trial(r).time, obj.trial(r).vY2, newTime);
                    vTras = hypot(vX1, vX2);
                    vTras(isnan(vTras)) = 0; %reemplazo los nan por 0
                    vRot = rad2deg((vY1 + vY2)/obj.ballDiameter);
                    vRot(isnan(vRot)) = 0; %reemplazo los nan por 0
                    dir = atan2d(-(vX2), vX1);
                    dir(isnan(dir)) = 0; %reemplazo los nan por 0
                    % Correccion de los angulos negativos que genero atan2d. 
                    % El viejo iba de 0-180 >0 y 0-180<0, ahora de 0 a 360.
                    dir = angTo360(dir);
                    if useSmooth
                        vTras = smooth(vTras, span, method);
                        vRot = smooth(vRot, span, method);
                        %dir = smooth(dir, span, method);
                        vX1 = smooth(vX1, span, method);
                        vX2 = smooth(vX2, span, method);
                    end
                        
                    intpRuns(nr).vTras = vTras;
                    intpRuns(nr).vRot = vRot;
                    intpRuns(nr).dir = dir;
                    intpRuns(nr).time = newTime;
                    intpRuns(nr).vX1 = vX1;
                    intpRuns(nr).vX2 = vX2;
                end
            end
        end
        function means = getStimsMean(obj,stimIND,varargin)
            binSize = 50; %ms
            useSmooth = false;
            span = 5;
            method = 'moving';
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'smooth'
                        useSmooth = varargin{arg+1};
                    case 'span'
                        span = varargin{arg+1};
                    case 'smoothmethod'
                        method = varargin{arg+1};
                    case 'binsize'
                        binSize = varargin{arg+1};
                    otherwise
                        error(['invalid optional argument: ' varargin{arg}])
                end
            end
            runs = obj.interpolateRuns(stimIND, binSize/1000,'smooth',useSmooth, 'span',span,'smoothmethod',method);
            l = zeros(1,length(stimIND));
            for i = 1:length(stimIND)
                l(i) = length(runs(i).time);
            end
            
            minL = min(l);
            means.time = runs(1).time-10;
           n = length(runs);
            vTras = zeros(length(runs),minL);
            vRot = zeros(length(runs),minL);
            dirComp = zeros(length(runs),minL);
            vX1 = zeros(length(runs),minL);
            vX2 = zeros(length(runs),minL);
            % calculo los promedios
            for i = 1:n
                vTras(i,:) = runs(i).vTras(1:minL);
                vRot(i,:) = runs(i).vRot(1:minL);
                vX1(i,:) = runs(i).vX1(1:minL);
                vX2(i,:) = runs(i).vX2(1:minL);
                dirComp(i,:) = exp(i * deg2rad(runs(i).dir(1:minL))); % Convert to complex numbers
            end

            vTrasStd = std(vTras,1,1);
            means.vTras = [mean(vTras,1);vTrasStd;vTrasStd/sqrt(n)];
            vRotStd = std(vRot,1,1);
            means.vRot = [mean(vRot,1);vRotStd;vRotStd/sqrt(n)];
            vX1Std = std(vX1,1,1);
            means.vX1 = [mean(vX1,1);vX1Std;vX1Std/sqrt(n)];
            vX2Std = std(vX1,1,1);
            means.vX2 = [mean(vX2,1);vX2Std;vX2Std/sqrt(n)];
            dirStd = std(dirComp,1,1);
            means.dir = [rad2deg(angle(mean(dirComp,1)));rad2deg(angle(dirStd));rad2deg(angle(dirStd/n)) ]; % Convert back to degrees
            
        end
    end
end