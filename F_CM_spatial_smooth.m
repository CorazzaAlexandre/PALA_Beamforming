function Rl = F_CM_spatial_smooth(Xsig, L)
% Covariance matrix estimation with spatial smoothing (forward method)
% Alexandre Corazza (13/10/2021)

    Rl = zeros(L,L);
    M = size(Xsig,1);
    
%     Method 1: for loop
%     for l = 1 : (M-L+1)
%         Xl = Xsig(l:l+L-1);
%         Rl = Rl + Xl*Xl';
% %         Rl = Rl + (Xl-mean2(Xl))*(Xl-mean2(Xl))';
%     end

    %Method 2: matrix computation (faster)
    Xl = buffer(Xsig, L, L-1); %reshape with overlapping
    if (M-L+1)+1 < size(Xl, 2) %we only take the M-L+1 last since the buffer function adds 0 values at the beginning sometimes
        Xl = Xl(:, end-(M-L+1)+1:end); 
    end
    Rl = Xl*Xl';

    Rl = Rl/(M-L+1);
end

