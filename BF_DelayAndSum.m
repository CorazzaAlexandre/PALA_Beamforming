function IQ = BF_DelayAndSum(SIG, PARAM, X, Z)
%% function IQ = BF_DelayAndSum(SIG, PARAM, X, Z)
% Delay And Sum beamforming with compounding or not, without apodization
%
% INPUTS:
%   - SIG: RF signal matrix or demodulated signal (RF_IQ)
% if compound, SIG must be a dictionnary with different signals obtained with the angles in angles_list
%
%   - PARAM: structure containing:
%       - f0: central frequency of US wave
%       - fs: sampling frequency
%       - t0: start time of receiving signal
%       - c: speed of sound in the medium
%       - Nelements: number of elements
%       - pitch: distance between 2 centers of element
%       - width: width of 1 element
%       - xe: position of the elements center on the x axis in m (0 is the
%             middle of the axis)
%       - fnumber: f-number given by the function F_fnumber
%       - theta: angle of emission in radian
%       - compound: set to 1 if you want to do compounding, 0 else
%       - angles_list: list of angles if you do compounding
%   - X, Z: grid of pixel (in m) (use meshgrid)
%
% OUTPUTS:
%   - IQ: Beamformed image (in linear scale, you need to log compress it)
%
% Alexandre Corazza, 13/10/2021

IQ = zeros(size(X),class(SIG{1}));

if ~isfield(PARAM, 'compound')
    PARAM.compound = 1;
end

for k = 1:length(PARAM.angles_list)
    PARAM.theta = PARAM.angles_list(k);
    if PARAM.compound
        IQ = IQ+BF_das_rephaseSignal(SIG{k}, PARAM, X, Z);
    else
        IQ(:,:,k) = BF_das_rephaseSignal(SIG{k}, PARAM, X, Z);
    end
end

end