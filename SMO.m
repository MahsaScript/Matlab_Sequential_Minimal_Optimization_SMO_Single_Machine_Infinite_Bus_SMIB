% clear all
%%Set motor parameter
ls = 0.0085;
rs = 2.875;
rated_flux = 0.175;
Pole_pair = 4;

%%Run PMSM control model
SampingTime = 0.000001;
sim('pmsm_ideal/pmsm_ideal.slx');
DataLength = length(V);

%%Sliding Mode Observer Parameter
I_hat=[0;0];
I_Gradient_hat=[0;0];
k = 200;

%%Log Data
BackEMFCommandLog(1:DataLength,1:2) = 0; 
BackEMFAfterLPFLog(1:DataLength,1:2) = 0;
EstimateTheata(1:DataLength) = 0;
EstimateW(1:DataLength) = 0;
EstimateWAfterLPF(1:DataLength) = 0;
EstimateTheataAfterCompensate(1:DataLength) = 0;
RealAngle(1:DataLength) = 0;

for i=1:DataLength
    %%Sliding Mode Obsevvation
    I_hat = I_hat +  SampingTime * I_Gradient_hat;
    %k*sign(I_hat-I(i,:)') >= Max(ea,eb)
    u = k*sign(I_hat-I(i,:)');
    I_Gradient_hat = V(i,:)' / ls - I_hat * (rs/ls) - u /ls; 
    BackEMFCommandLog(i,1:2) = u;
    if (i == 1)
        continue;
    end 
    %%Get Back-EMF on Clarke axis
    %First order butterworth filter, cut-off Freq=50hz
    BackEMFAfterLPFLog(i,:) = 0.00015705*BackEMFCommandLog(i,:)'+0.00015705*BackEMFCommandLog(i-1,:)' + 0.99968*BackEMFAfterLPFLog(i-1,:)';
    
    %%Get Estimate Electrical Angle
    EstimateTheata(i) = atan2(-BackEMFAfterLPFLog(i,1),BackEMFAfterLPFLog(i,2));
    %Shift(-pi to pi)
    if(EstimateTheata(i) < 0)
        EstimateTheata(i) = 2*pi+EstimateTheata(i);
    end
    
    %%Get Estimate Electrical Speed
    EstimateW(i) = (EstimateTheata(i) - EstimateTheata(i-1));
    %Compensate phase change  
    if( EstimateW(i) > pi)
        EstimateW(i) =  2*pi-EstimateW(i);
    elseif ( EstimateW(i) < -pi)
        EstimateW(i) =  2*pi+EstimateW(i);
    end
    EstimateW(i) = EstimateW(i) / SampingTime;
    
    %First order butterworth filter, cut-off Freq=50hz
    EstimateWAfterLPF(i) =  0.00015705*EstimateW(i)+0.00015705*EstimateW(i-1) + 0.99968*EstimateWAfterLPF(i-1);
    
    %%Compensate Estimate Electrical Angle phse shift
    EstimateTheataAfterCompensate(i) = EstimateTheata(i) + atan(EstimateWAfterLPF(i)/(100*pi)); 
    if(EstimateTheataAfterCompensate(i) > 2*pi)
        EstimateTheataAfterCompensate(i) = EstimateTheataAfterCompensate(i) - 2 * pi;
    end
    
    %%Get Real Electrical Angle
    RealAngle(i) = atan2(sin(theata(i)),cos(theata(i)));
    %Shift(-pi to pi)
    if(RealAngle(i) < 0)
        RealAngle(i) = 2*pi+RealAngle(i);
    end
end


T = [0:SampingTime:SampingTime*(DataLength-1)];
%%Plot Estimate Angle and Speed
figure('Name','SMO Data');
subplot(2,1,1);
plot(T,EstimateTheata);
title('SMO  Estimate Electrical Theata');
xlabel('time')
ylabel('£c');

subplot(2,1,2); 
plot(T,EstimateWAfterLPF)
title('SMO  Estimate Electrical Speed');
ylabel('W');
xlabel('time')

%%Real Angle and SMO Angle
figure('Name','Real Angle and SMO Angle');
plot(T,RealAngle);
hold on
plot(T,EstimateTheataAfterCompensate,'--');
hold off
xlabel('time')
ylabel('£c');
legend('RealAngle','Senserless Angle')


