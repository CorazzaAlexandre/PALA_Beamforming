function IQ = BF_pDAS(SIG, PARAM, X, Z)
%% function IQ = BF_MinimumVariance(SIG, PARAM, X, Z)
% pDAS beamforming with compounding or not
% INPUTS:
%   - SIG: RF or IQ signal matrix

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
%       - p_pDAS: power p of pDAS

%   - X, Z: grid on pixel (use meshgrid)

% OUTPUTS:
%   - IQ: Beamformed image (in linear scale, you need to log compress it)

% Alexandre Corazza, 13/10/2021


BF = zeros(size(X));
epsilon_0 = 1e-30; %avoid to divide by 0

if ~isfield(PARAM, 'compound')
    PARAM.compound = 0;
end

if ~PARAM.compound
    migSIG = F_BF_SIG_rephase(SIG, PARAM, X, Z);
    weights = abs(migSIG+epsilon_0) .^ ((1-PARAM.p_pDAS)/PARAM.p_pDAS);

    BF = sum(migSIG .* weights, 3);
    BF = sign(BF) .* (abs(BF).^PARAM.p_pDAS); %idem que la ligne dessous pour les IQ
%     BF = exp(1i*angle(BF)) .* (abs(BF).^PARAM.p_pDAS);
    
elseif PARAM.compound %Compounding
    for k = 1:length(PARAM.angles_list)
        PARAM.theta = PARAM.angles_list(k);
        migSIG = F_BF_SIG_rephase(PARAM.SIG_list{k}, PARAM, X, Z);
        weights = abs(migSIG+epsilon_0) .^ ((1-PARAM.p_pDAS)/PARAM.p_pDAS);

        BF = sum(migSIG .* weights, 3);
        BF = BF + sign(BF) .* (abs(BF).^PARAM.p_pDAS); 
    end
end

IQ = BF;
    
end