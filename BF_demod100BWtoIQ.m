function RF_IQ = BF_demod100BWtoIQ(RF_100BW)
%% function RF_IQ = BF_demod100BWtoIQ(RF_100BW)
% Convert signal samples at 100BW to a complex signal (RF_IQ)
%
% INPUTS:
%   - RF_100BW: RF sampled with Verasonics 100% bandwidth mode {RF(nT+0) RF(nT+T/4) RF((n+1)T) RF((n+1)T+T/4)...}
% OUTPUTS:
%   - RF_IQ: IQ signal sampled at f0
%
% Alexandre Corazza, 15/12/2021

% In_phase = SIG_100BW(1:2:size(SIG_100BW, 1), :); % {RF(nT+0) RF((n+1)T+0)...}
% in_Quad = SIG_100BW(2:2:size(SIG_100BW, 1), :); % {RF(nT+T/4) RF((n+1)T+T/4)...}
% 
% SIG_IQ = In_phase - 1j*in_Quad;

RF_IQ = RF_100BW(1:2:end-1,:) - 1j*RF_100BW(2:2:end,:);
end