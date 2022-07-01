function Rl = F_CM_forward_backward(Xsig, L)
% Covariance matrix estimation with spatial smoothing (forward-backward method)
% Alexandre Corazza (13/10/2021)

    M = size(Xsig,1);

    Rl1 = F_CM_spatial_smooth(Xsig, L);
    J = fliplr(eye(size(Rl1)));
    Rl2 = J*(Rl1.')*J;

    Rl = (1/(2*(M-L+1)))*(Rl1 + Rl2);
    
end

