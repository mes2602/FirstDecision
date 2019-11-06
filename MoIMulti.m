function R = MoIMulti(z,l,h,time)

    funP =@(x,time,D,mu) (1/sqrt(4*pi*D*time))* (exp((-(x-mu*time).^2)/(4*D*time)) - ...
            exp((mu*z)/D)*exp((-(x-2*z-mu*time).^2)/(4*D*time))...
            - exp(-(mu*z)/D)*exp((-(x+2*z-mu*time).^2)/(4*D*time)));
        
     Rpp = integral(@(x)funP(x,time,1,1),l,h);
     Rpm = integral(@(x)funP(x,time,1,-1),l,h);
     R = log(Rpp/Rpm);
end