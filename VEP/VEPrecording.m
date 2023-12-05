classdef VEPrecording < handle
    properties
        path string;
        VEPs struct;
        sampleRate;
        groupList cell;
        name string
    end
    methods
        %constructor from "loadVEPs"
        function obj = VEPrecording(reg)
            obj.path = reg.path;
            obj.VEPs = reg.VEPs;
            obj.sampleRate = reg.sampleRate;
            if isfield(reg, 'group')
                obj.groupList = {reg.group};
            else
                obj.groupList = {};
            end
            if isfield(reg, 'name')
                obj.name =  reg.name;
            else
                obj.name = obj.getDateName(reg.path);
            end
        end
        
        function addGroup(obj, groupName)
            %agrega un nuevo grupo a la lista de grupos de neuronas que se
            %encontraron en este registro
            %si el grupo ya está incluído no hace nada
            if ~sum(strcmp(obj.groupList, groupName))
                obj.groupList = [obj.groupList, groupName];
            end
        end
        
        function dateName = getDateName(obj, file)
            if isstring(file)
                file = char(file);
            end
            f = file(25:end);
            for ch = 1:length(f)
                if f(ch) == 't'
                    dateName = f(1:ch-2);
                    return
                end
            end
            error('no puedo resolver el nombre del archivo')
        end
        
        function [time, VEP] = getVEP2plot(obj, stim, varargin)
            %Devuelve los trazos correspondientes a el estímulo
            %seleccionado.
            %
            %   'mean'   ---> devuelve el trazo medio de los trials
            
            useMean = false;
            
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'mean'
                        useMean = varargin{arg+1};
                    otherwise
                        disp(['"', varargin{arg}, '" is not a valid argument'])
                end
            end
            acumVEP = [];
            for st = stim
                for s = 1:length(obj.VEPs)
                    
                    if obj.VEPs(s).stim == st
                        break
                    elseif s == length(obj.VEPs)
                        disp(['stim ', num2str(st), ' not found'])
                        time = [];
                        VEP = [];
                        return
                    end
                end
                
                VEP = obj.VEPs(s).traces;
                if useMean
                    VEP = mean(VEP, 2);
                end
                if isempty(acumVEP)
                    acumVEP = VEP;
                else
                    acumVEP = acumVEP + VEP;
                end
            end
            VEP = acumVEP / length(stim);
            time = 0:1/obj.sampleRate:(length(VEP)-1) / obj.sampleRate;
            time = time - 10;
        end
        
        function [f, p] = getFreqSpectrum(obj, stim, varargin)
            %devuelve las frecuencias (f) y potencias (p) unidireccionales
            %de una transformada de fourier.
            %
            %   'plot'   ---> genera un gráfico de f vs p
            % 
            %   'xlim'   ---> setea los limites de frecuencia del eje
            %                 horizontal en el gráfico de la opción 'plot'
            %
            %   'bounds' ---> setea los tiempos entre los que se analiza el
            %                 registro.
            makePlot = false;
            xlimit = [0 30];
            bounds = [];
            norm = false;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'plot'
                        makePlot = varargin{arg+1};
                    case 'xlim'
                        xlimit = varargin{arg+1};
                    case 'bounds'
                        bounds = varargin{arg+1};
                    case 'norm'
                        norm = varargin{arg+1};
                    otherwise
                        error(['"', varargin{arg}, '" is not a valid argument'])
                end
            end
            Fs = obj.sampleRate;
            [time, VEP] = obj.getVEP2plot(stim, 'mean', true);

            if ~isempty(bounds)
                tmin = min(time);
                tmax = max(time);
                for i = 1:length(time)
                    if bounds(1) <= time(i)
                        tmin = time(i);
                        break
                    end
                end
                for i = length(time):-1:1
                    if bounds(2) >= time(i)
                        tmax = time(i);
                        break
                    end
                end
                t = time(time >= tmin & time <= tmax);
                VEP = VEP(time >= tmin & time <= tmax);
            else
                t = time;
            end
            
            L = length(t);
            Y = fft(VEP);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(L/2))/L;
            if makePlot
                figure
                plot(f,P1) 
                title('Single-Sided Amplitude Spectrum of VEP(t)')
                xlabel('f (Hz)')
                ylabel('|P1(f)|')
                xlim(xlimit)
            end
            if strcmp(norm, 'psd')
                p = P1 / sum(P1);
            elseif strcmp(norm, 'peak')
                p = P1 / max(P1);
            else
                p = P1;
            end
        end
        
        function [t, f, ps] = spectrogram(obj, stim, varargin)
            dt = 5;
            fmax = 30;
            norm = 'psd';
            bounds = [-10 20];
            makePlot = true;
            for arg = 1:2:length(varargin)
                switch lower(varargin{arg})
                    case 'plot'
                        makePlot = varargin{arg+1};
                    case 'fmax'
                        fmax = varargin{arg+1};
                    case 'dt'
                        dt = varargin{arg+1};
                    case 'bounds'
                        bounds = varargin{arg+1};
                        if length(bounds) ~= 2 || bounds(1) > bounds(2)
                            error('el argumento "bounds" tiene que ser un vector con dos valores de menor a mayor')
                        end
                    case 'norm'
                        norm = varargin{arg+1};
                    otherwise
                        error(['"', varargin{arg}, '" is not a valid argument'])
                end
            end
            
            t = bounds(1):dt:bounds(2)-dt;
            ps = [];
            for nt = 1:length(t)
                [f, p] = obj.getFreqSpectrum(stim, 'bounds', [t(nt), t(nt)+dt], 'norm', norm);
                f = f(f<= fmax);
                p = p(1:length(f));
                ps(:,nt) = p;
                %plot(f, p)
                %xlim([0 30])
            end
            if makePlot
                figure
                hold on
                pc = pcolor(t,f,ps);
                pc.FaceColor = 'interp';
                pc.EdgeColor = 'none';
                ylim([0,10])
                hold off
            end
            %legend({'-10:-5', '-5:0', '0:5', '5:10', '10:15', '15:20'});
        end
    end
    
end
