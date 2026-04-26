clc; clear; close all;

%% PARAMETERS

dt = 60;                     % time step (s)
t_end = 24*3600;            % 24 hrs
t = 0:dt:t_end;

n = length(t);

% Room properties
V = 5*4*3;                  % room volume (m^3)
rho = 1.225;                % air density (kg/m^3)
cp = 1005;                  % specific heat air (J/kgK)
m = rho*V;                  % air mass

UA = 180;                   % heat transfer coefficient (W/K)

% HVAC system
Qmax = 4000;                % max heating/cooling power (W)
Tset = 23;                  % desired temp (deg C)

% Initial room temp
Troom = zeros(1,n);
Troom(1) = 28;

% HVAC power record
Qhvac = zeros(1,n);

%% OUTDOOR TEMPERATURE (Melbourne style day)

Tout = 18 + 7*sin(2*pi*(t/(24*3600)) - pi/2);

%% OCCUPANCY HEAT LOAD

Qpeople = zeros(1,n);

for i = 1:n
    hour = t(i)/3600;

    if hour >= 8 && hour <= 17
        people = 3;
    else
        people = 0;
    end

    Qpeople(i) = people * 100;   % 100 W per person
end

%% MAIN SIMULATION

for i = 1:n-1

    % Smart HVAC control
    error = Tset - Troom(i);

    Qhvac(i) = 800 * error;

    % limit system capacity
    if Qhvac(i) > Qmax
        Qhvac(i) = Qmax;
    elseif Qhvac(i) < -Qmax
        Qhvac(i) = -Qmax;
    end

    % Energy balance
    dTdt = (Qhvac(i) + Qpeople(i) ...
          - UA*(Troom(i)-Tout(i))) / (m*cp);

    Troom(i+1) = Troom(i) + dTdt*dt;
end

%% ENERGY USE

Energy_kWh = sum(abs(Qhvac))*dt/3600/1000;

fprintf('Total HVAC Energy Used = %.2f kWh\n',Energy_kWh);

%% PLOTS

figure;

subplot(3,1,1)
plot(t/3600,Troom,'LineWidth',2)
hold on
plot(t/3600,Tout,'--','LineWidth',1.5)
yline(Tset,'r:')
xlabel('Hour')
ylabel('Temp (C)')
legend('Room','Outdoor','Setpoint')
title('Room vs Outdoor Temperature')
grid on

subplot(3,1,2)
plot(t/3600,Qhvac,'LineWidth',2)
xlabel('Hour')
ylabel('HVAC Power (W)')
title('HVAC Operation')
grid on

subplot(3,1,3)
plot(t/3600,Qpeople,'LineWidth',2)
xlabel('Hour')
ylabel('Heat Load (W)')
title('Occupancy Heat Gain')
grid on