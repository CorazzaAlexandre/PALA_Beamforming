function xt = F_BF_iMAP(PARAM, X, Z)
% iMAP method
% INPUTS:
%   - PARAM: structure containing:
%       - f0: central frequency of US wave
%       - fs: sampling frequency
%       - t0: start time of receiving signal
%       - c: speed of sound in the medium
%       - Nelements: number of elements
%       - pitch: distance between 2 centers of element
%       - width: width of 1 element
%       - xe: position of the elements center on the x axis in mm (0 is the
%             middle of the axis)
%       - fnumber: f-number given by the function F_fnumber
%       - theta: angle of emission in radian
%       - compound: set to 1 if you want to do compounding, 0 else
%       - angles_list: list of angles if you do compounding
%       - SIG_list: dictionnary with different signals obtained with the
%                   angles in angles_list
%       - Rcov_method: method to estimate the covariance matrix
%           - 'classic': no estimation
%           - 'FW': forward method (spatial smoothing)
%           - 'FWBW': forward backward method
%           - 'Tabasco': tapering
%           - 'cross': cross covariance matrix
%       - DeltaDL: amount of diagonal loading ==> R_DL = R + (DeltaDL/L)*trace(R)*I
%       - K: number of additive samples of temporal smoothing (set to 0 if
%       you don't want temporal smoothing)
%       - dtau: time sample step for temporal smoothing
%       - tapering: boolean (0 if you want to taper, 1 else)
%       - Dtaper: amount of uncertainties in the tapering matrix
%       - capon_approach: 'amplitude' or 'power'
%   - X, Z: grid on pixel (use meshgrid)

% OUTPUTS:
%   - BF: Beamformed image (in linear scale, you need to log compress it)

% Alexandre Corazza, 13/10/2021


migSIG = 0;
for k = 1:length(PARAM.angles_list)
    PARAM.theta = PARAM.angles_list(k);
    migSIG = migSIG + F_BF_SIG_rephase(PARAM.SIG_list{k}, PARAM, X, Z);
end
migSIG = migSIG./length(PARAM.angles_list);

xt = F_BF_das(migSIG, PARAM, X, Z); %x0

for kx = 1:length(PARAM.x)
    for kz = 1:length(PARAM.z)
        
        Y = migSIG(kz, kx, :);
        Y = Y(:);
        M = length(Y);
        
        for kstep = 1:PARAM.Nstep_iMAP
            
            sigma_X = abs(xt(kz,kx))^2;
            sigma_N = (1/M) * norm(Y - xt(kz,kx).*ones(length(Y), 1))^2;
            
            xt(kz,kx) = sigma_X/(sigma_N + M*sigma_X) * xt(kz,kx);
        end
             
       
    end
end
end
