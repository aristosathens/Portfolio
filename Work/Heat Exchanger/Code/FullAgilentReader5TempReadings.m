%--------------------------AGILENT_COMPLETEREADER--------------------------%

%This code measures temperature data and plots it. From that it calculates
%effectiveness.





%-------------------------USER INPUT/INITIALIZE-------------------------%

close all

%Asks the user for input. Checks to ensure valid inputs were used.
boolean = false;

while boolean == false

    prompt = {'IMPORTANT: Input the current volumetric FLOW RATE setting in ml/min: ',...
        'IMPORTANT: Input the VOLTAGE setting on the power source in volts',...
        'IMPORTANT: Input the CURRENT setting on the power source in amps',...
        'Input the current room temperature in degrees C: ',...
        'Input specific heat of the hot fluid in kJ/(kg K): ','Input the density of the hot fluid in kg/(m^3): ',...
        'Input the specific heat of the cold fluid in kJ/(kg K): ', 'Input the density of the cold fluid in kg/(m^3): '};
    dlg_title = 'User Input - Defaults are water values';
    num_lines = 1;
    defaultans = {'XXXXX','XXXXX','XXXXX','22','4.18','998','4.18','983'};
    inputVector = inputdlg(prompt,dlg_title,num_lines,defaultans);

    %Checks if user input are valid numbers.
    for i = 1:length(inputVector)
        if ~(any(isletter(inputVector{i}))) && (str2num(inputVector{i}) >= 0)
            %Converts user input into variables for calculations
            volumetricFlowRate = str2num(inputVector{1})*(1.66667e-8);
            roomTemp = str2num(inputVector{4});
            specificHeatHot = str2num(inputVector{5});
            densityHot = str2num(inputVector{6});
            specificHeatCold = str2num(inputVector{7});
            densityCold = str2num(inputVector{8});
            %Breaks the while loop
            boolean = true;
        else
            h = msgbox('Invalid inputs. Inputs must be positive numbers. Try again.')
            boolean = false;
            uiwait(h);
            break
        end
    end

end




%Calculates mass flow rates, Heats, and minimum Heat
heatHot = volumetricFlowRate*densityHot*specificHeatHot;
heatCold = volumetricFlowRate*densityCold*specificHeatCold;
minimumHeat = min(heatHot,heatCold);

%Changes flow rate and heater voltage to string for autosave purposes
flowRateString = strcat(inputVector{1}, 'ml per min,');
heaterVoltageString = strcat(inputVector{2}, 'Vheater');
heaterCurrentString = strcat(inputVector{3}, 'Aheater');


%Initialize the graphing parameters
step_time = 1; %step time in seconds;
scan_time = 3*3600; %total scan leangth in seconds
scan_length = round(scan_time/step_time);
data = zeros(scan_length, 200);
plot_interval = 5; %plot and save data every x measurements

t = zeros(scan_length, 1);
T1 = zeros(scan_length, 1);
T2 = zeros(scan_length, 1);
T3 = zeros(scan_length, 1);
T4 = zeros(scan_length, 1);
T5 = zeros(scan_length, 1);
E = zeros(scan_length, 1);

%V1 = zeros(scan_length, 1);
%V2 = zeros(scan_length, 1);



%----------------------CONNECT TO AGILENT MACHINE----------------------%



% Find a VISA-USB object.
obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0957::0x2007::MY49017388::0::INSTR', 'Tag', '');
%obj1 = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0957::0x2007::MY49017388::0', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.

if isempty(obj1)
        obj1 = visa('Agilent', 'USB0::0x0957::0x2007::MY49017388::0::INSTR');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

% Communicating with instrument object, obj1.
fprintf(obj1, '*RST');
fprintf(obj1, '*CLS');

%FOR AGILENT, TEMP CHANNELS ARE 105,106,107,109,110 AS OF SEPT 22, 2016



fprintf(obj1, 'CONF:TEMP TC,T, (@105:107,109,110)');
%fprintf(obj1, 'CONF:VOLT:DC (@108)');%added voltage
%%%%%fprintf(obj1, 'CONF:VOLT:DC 10,DEF,(@110, 111)');%added voltage
%fprintf(obj1,'SENS:VOLT:DC,(@108)');%added voltage
%%%%%fprintf(obj1,'SENS:VOLT:DC:NPLC 10,(@110, 111)');%added voltage
fprintf(obj1, 'SENS:TEMP:TRAN:TYPE TC, (@105:107,109,110)');
fprintf(obj1, 'SENS:TEMP:TRAN:TC:TYPE T, (@105:107,109,110)');
fprintf(obj1, 'SENS:TEMP:TRAN:TC:RJUN:TYPE INT, (@105:107,109,110)');
fprintf(obj1, 'SENS:TEMP:TRAN:TC:CHEC OFF, (@105:107,109,110)');
fprintf(obj1, 'UNIT:TEMP C, (@105:107,109,110)');

fprintf(obj1, 'FORM:READ:UNIT OFF');
fprintf(obj1, 'FORM:READ:CHAN OFF');
fprintf(obj1, 'FORM:READ:TIME ON');
fprintf(obj1, 'FORM:READ:TIME:TYPE ABS');
%fprintf(obj1, 'READ?');
fprintf(obj1, 'ROUT:SCAN (@105:107,109,110)');






%-------------------GRAPHING/DYNAMIC CALCULATIONS-------------------%

figure
set(gcf, 'color', 'white');
hold on
fmt = '%f%f%f';


for i = 1:scan_length
    tic
% Communicating with instrument object, obj1.
data(i, :) =  query(obj1, 'READ?');


if i ==1
    start_time_char = char(data(i, 17:40));
    t_o =  textscan(char(data(i, 28:40)),fmt,'delimiter',',');
    hrs_o = t_o{1}; min_o = t_o{2}; sec_o = t_o{3};
end

T1(i) = str2num(char(data(i, 1:15)));
T2(i) = str2num(char(data(i, 41:55)));
T3(i) = str2num(char(data(i, 80:95)));
T4(i) = str2num(char(data(i, 120:135)));
T5(i) = str2num(char(data(i, 160:175)));

%Calculates basic effectiveness from T1, T2, and roomTemp
qHotLoss = heatHot*(T1(i) - T4(i));
qColdGain = heatCold*(T2(i) - T3(i));
E(i) = qColdGain/qHotLoss;

t_now = textscan(char(data(i, 28:40)),fmt,'delimiter',',');
hrs_now = t_now{1}; min_now = t_now{2}; sec_now = t_now{3};
t(i) = (hrs_now-hrs_o)*3600+(min_now-min_o)*60+(sec_now-sec_o);

if mod(i, plot_interval) == 0
subplot(2, 3, 1)
plot(t(i-plot_interval+1:i), T1(i-plot_interval+1:i), 'r.'); hold on; grid on; title('Temp 1 - Hot In (C)')
xlabel('time(sec)')
subplot(2, 3, 2)
plot(t(i-plot_interval+1:i), T2(i-plot_interval+1:i), 'g.'); hold on; grid on; title('Temp 2 - Cold Out (C)')
xlabel('time(sec)')
subplot(2, 3, 3)
plot(t(i-plot_interval+1:i), T3(i-plot_interval+1:i), 'b.'); hold on; grid on; title('Temp 3 - Cold In (C)')
xlabel('time(sec)')
subplot(2, 3, 4)
plot(t(i-plot_interval+1:i), T4(i-plot_interval+1:i), 'm.'); hold on; grid on; title('Temp 4 - Hot Out (C)')
xlabel('time(sec)')
subplot(2, 3, 5)
plot(t(i-plot_interval+1:i), T5(i-plot_interval+1:i), 'c.'); hold on; grid on; title('Temp 5 - Heater (C)')
xlabel('time(sec)')

subplot(2, 3, 6)
plot(t(i-plot_interval+1:i), E(i-plot_interval+1:i), 'k.'); hold on; grid on; title('Effectiveness')
xlabel('time(sec)')

%subplot(2, 2, 2)
%plot(t(i-plot_interval+1:i), V1(i-plot_interval+1:i), 'k.'); hold on; grid on; title('V1')
%subplot(2, 2, 4)
%plot(t(i-plot_interval+1:i), V2(i-plot_interval+1:i), 'b.'); hold on; grid on; title('V2')
end

clc
disp(strcat('t: ', num2str(t(i))))
disp(strcat('T1: ', num2str(T1(i))))
disp(strcat('T2: ', num2str(T2(i))))
disp(strcat('T3: ', num2str(T3(i))))
disp(strcat('T4: ', num2str(T4(i))))
disp(strcat('T5: ', num2str(T5(i))))
disp(strcat('E: ', num2str(E(i))))

pause(step_time-toc)


%This creates the date string for the file name. It cuts off the minutes
%and seconds, give you the date plus the hours in military time (i.e.
%17hour for 5pm)
dateString=strcat(datestr(clock,'yyyy-mm-dd-HH'),'hour'); 


%Creates the filename using "HX Test Data", the current date, and the given
%flow rate
fileNameString = strcat('HX Test Data, ', flowRateString, heaterVoltageString,...
    heaterCurrentString, dateString, '.mat');
save(fileNameString); 
end


% Disconnect from instrument object, obj1.
fclose(obj1);