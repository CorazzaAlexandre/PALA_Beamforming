function IQ = BF_MinimumVariance(SIG, PARAM, X, Z)
%% function IQ = BF_MinimumVariance(SIG, PARAM, X, Z)
% Capon method with covariance matrix estimation by spatial smoothing or
% forward-backward method
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
%       - Rcov_method: method to estimate the covariance matrix
%           - 'classic': no estimation
%           - 'FW': forward method (spatial smoothing)
%           - 'FWBW': forward backward method
%       - DeltaDL: amount of diagonal loading ==> R_DL = R + (DeltaDL/L)*trace(R)*I
%       - capon_approach: 'amplitude' or 'power'
%   - X, Z: grid on pixel (use meshgrid)

% OUTPUTS:
%   - IQ: Beamformed image (in linear scale, you need to log compress it)

% Alexandre Corazza, 13/10/2021

BF = zeros(length(PARAM.z), length(PARAM.x));

tic

% All the signal rephasing here
for k = 1:length(PARAM.angles_list)
    PARAM.theta = PARAM.angles_list(k);
    PARAM.migSIG_list{k} = F_BF_SIG_rephase(PARAM.SIG_list{k}, PARAM, X, Z);
%     PARAM.migSIG_list{k} = F_BF_SIG_rephase(PARAM.SIG_list(:,:,k), PARAM, X, Z);
end

fwait= waitbar(0);
for kx = 1:length(PARAM.x)
    waitbar(kx/(length(PARAM.x)),fwait, num2str(toc));
    for kz = 1:length(PARAM.z)
                
        Rl = 0;
        B = 0;
        
        %we do not take zeros values due to f-number to avoid shadow area on the edges
        %so we are looking for first and last non-zero value in the rephased signal
        min_first_nonzero = PARAM.Nelements+1;
        max_last_nonzeros = 0;
        for kangle = 1:length(PARAM.angles_list)
            migSIGk = PARAM.migSIG_list{kangle};
            Xsig = migSIGk(kz, kx, :);
            Xsig = Xsig(:);
            
            CXsig = cumsum(Xsig);
            first_nonzero = find(Xsig~=0, 1, 'first');
            last_nonzeros = find(CXsig==CXsig(end), 1, 'first');
            
            min_first_nonzero = min(first_nonzero, min_first_nonzero);
            max_last_nonzeros = max(last_nonzeros, max_last_nonzeros);
        end
        
        for kangle = 1:length(PARAM.angles_list)

            migSIGk = PARAM.migSIG_list{kangle};
            Xsig = migSIGk(kz, kx, :);
            Xsig = Xsig(:);
            Xsig = Xsig(min_first_nonzero:max_last_nonzeros);
            M = length(Xsig);
            L = floor(M*PARAM.LoverM);
            
            %Covariance matrix
                if isequal(PARAM.Rcov_method, 'FW')
                    Rl = Rl + F_CM_spatial_smooth(Xsig, L);
                else
                    Rl = Rl + F_CM_forward_backward(Xsig, L);
                end
           
            %we take the mean of the rephased signal to reduce computing
            %time
            for l = 1:M-L+1
                Xl = Xsig(l:l+L-1);
                B = B + Xl;
            end
                  
    
        if kangle == length(PARAM.angles_list)
                       
            Rhat = Rl / length(PARAM.angles_list);

            if trace(abs(Rhat))~=0 % (avoid inverting empty matrix in noiseless situation)
                %diagonal loading
                if ~isequal(PARAM.Rcov_method,'FWBW')
                Rhat = Rhat + eye(size(Rhat))*(PARAM.DeltaDL/L)*trace(abs(Rhat));
                end         

                %invert and weights computation
                invR = inv(Rhat);
                a = ones(L,1);
                a = a/norm(a);
                w = ( invR * a ) ./ (a' * invR * a);

            else
                B = 0;
                w = 0;
            end
            
            BF(kz,kx) = BF(kz,kx) + w'*B/(M-L+1);
        end
        
        end
    end
end

end