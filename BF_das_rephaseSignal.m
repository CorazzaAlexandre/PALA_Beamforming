function migSIG1 = BF_das_rephaseSignal(SIG, PARAM, X, Z)
% function migSIG1 = BF_das_rephaseSignal(SIG, PARAM, X, Z)
%
% Build the 3D matrix of rephased signals
%
% INPUTS:
%   - SIG: RF or RF_IQ signal matrix
%
%   - PARAM: structure containing:
%       - f0: central frequency of US wave
%       - fs: sampling frequency
%       - t0: start time of receiving signal
%       - c: speed of sound in the medium
%       - Nelements: number of elements
%       - pitch: distance between 2 centers of element
%       - width: width of 1 element
%       - fnumber:
%       - theta: angle of emission in radian
%       - compound: set to 1 if you want to do compounding, 0 else
%       - angles_list: list of angles if you do compounding
%       - win_apod: apodization at the reception
%
%   - X, Z: grid on pixel (use meshgrid)
%
% OUTPUTS:
%   - migSIG1: Beamformed image (in linear scale, you need to log compress it)
%
% Alexandre Corazza (13/10/2021)
% inspired from the function "dasmtx" of MUST toolbox, Damien Garcia http://www.biomecardio.com

if iscell(SIG)
    SIG_class = class(SIG{1});
else,SIG_class = class(SIG);
end

migSIG = zeros([1 numel(X)],SIG_class);

% emit delay
% TXdelay = (1/PARAM.c)*tan(PARAM.theta)*abs(PARAM.xe - PARAM.xe(1));

%source virtuelle
beta = 1e-8;
L = PARAM.xe(end)-PARAM.xe(1);
vsource = [-L*cos(PARAM.theta).*sin(PARAM.theta)/beta, -L*cos(PARAM.theta).^2/beta];

for k = 1:PARAM.Nelements
    % dtx = sin(PARAM.theta)*X(:)+cos(PARAM.theta)*Z(:); %convention FieldII
    % dtx = sin(PARAM.theta)*X(:)+cos(PARAM.theta)*Z(:) + mean(TXdelay)*PARAM.c; %convention FieldII
    % dtx = sin(PARAM.theta)*X(:)+cos(PARAM.theta)*Z(:) + mean(TXdelay-min(TXdelay))*PARAM.c; %convention Verasonics
    dtx = hypot(X(:)-vsource(1), Z(:)-vsource(2)) - hypot((abs(vsource(1))-L/2)*(abs(vsource(1))>L/2), vsource(2)); %source virtuelle, convention Verasonics
    drx = hypot(X(:)-PARAM.xe(k), Z(:));
    
    tau = (dtx+drx)/PARAM.c;
    
    %-- Convert delays into samples
    idxt = (tau-PARAM.t0)*PARAM.fs + 1;
    I = idxt<1 | idxt>(size(SIG,1)-1);
    idxt(I) = 1; % arbitrary index, will be soon rejected
    
    idx  = idxt;       % Not rounded number of samples to interpolate later
    idxf = floor(idx); % rounded number of samples
    IDX  = repmat(idx, [1 1 size(SIG,3)]); %3e dimension de SIG: angles
    
    %-- Recover delayed samples with a linear interpolation
    TEMP = SIG(idxf,k,:).*(idxf+1-IDX) + SIG(idxf+1,k,:).*(IDX-idxf);
    % TEMP = SIG(idxf, k, :);
    
    TEMP(I,:) = 0;
    
    if (~isreal(TEMP)) % if IQ signals, rephase
        TEMP = TEMP.*exp(2*1i*pi*PARAM.f0*tau);
    end
    
    % Fnumber mask
    mask_Fnumber = abs(X-PARAM.xe(k)) < Z/PARAM.fnumber/2;    
    migSIG = migSIG(:)+TEMP(:).*mask_Fnumber(:);
end

migSIG1=reshape(migSIG, size(X));

end
