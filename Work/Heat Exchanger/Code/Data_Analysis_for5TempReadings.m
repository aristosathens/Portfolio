%Get mean and std of steady-state region of Effectiveness vector. Graph Eff
%vs flow rate

%Initialize.
%Sets loop check to false.
%Creates empty data Matrix.
clear
close all
boolean = false;
dataFile = [];
color1 = 'r.';
color2 = 'g.';
color3 = 'k.';
color4 = 'o.';

dataFile1 = [0 0 0];
dataFile2 = [0 0 0];
dataFile3 = [0 0 0];
dataFile4 = [0 0 0];


for m = 1:4
    
    dataFile = [];
    boolean = false;
    inputBoolean = false;
    
    
%This loop asks user to select a file to upload. Repeats until the user
%says they are done uploading.
while boolean == false
    

%Clears the previously loaded values.
clear t
clear inputVector
clear t1
clear t2
clear T1
clear T2
clear T3
clear T4
clear T5
clear E
clear volumetricFlowRate
close all



%Loads the new workspace file to be examined. Only loads Effectiveness and
%flow rate
uiopen('load');
%Changes flow rate into ml/min instead of (m^3)/sec
flowRate = volumetricFlowRate/(1.66667e-8);


%Shows the user the graph of the E vs time, so they can find the steady
%state region.
subplot(2, 2, 1)
plot(t, T1, 'r.'); hold on; grid on; title('Temp 1 (C)')
xlabel('time(sec)')
subplot(2, 2, 2)
plot(t, T2, 'g.'); hold on; grid on; title('Temp 2 (C)')
xlabel('time(sec)');
subplot(2, 2, 3)
plot(t, T3, 'b.'); hold on; grid on; title('Temp 3 - Heater (C)')
xlabel('time(sec)');
subplot(2, 2, 4)
plot(t, E, 'k.'); hold on; grid on; title('Effectiveness')
xlabel('time(sec)');



%Finds maximum t value
maxT = find(t,1,'last');


inputBoolean = false;

while inputBoolean == false
    
    %Asks the user for input. Basically need to look at the graph, and decide
    %where the steady state region is for the E vector.
    promptString1 = strcat('IMPORTANT: Look at the data for flow rate of ', num2str(flowRate),...
    ' and find the steady state values. Enter the t1 and t2, the time values that define that region. T1: ');
    promptString2 = 'T2 (type "end" for the end of the graph): ';
    prompt = {promptString1, promptString2};
    num_lines = 1;
    defaultans = {'XXXXX','end'};
    inputVector = inputdlg(prompt,dlg_title,num_lines,defaultans);

    %Checks if user input for t1 is valid.
        if (~any(isletter(inputVector{1}))) && (str2num(inputVector{1}) > 0 && (str2num(inputVector{1}) < length(t)))
            %Converts user input into variables for calculations
            t1 = str2num(inputVector{1});
            %Breaks the while loop
            inputBoolean = true;
        else
            h = msgbox('Invalid input. t1 must be a positive number, less than length of x-axis. Try again.')
            inputBoolean = false;
            uiwait(h);
            continue
        end
        
        
     %Checks if user input for t2 is valid.
      if strcmp(inputVector(2),'end')
            t2 = int16(find(E,1,'last'));
            
      elseif ((any(isletter(inputVector{2})))) || (str2num(inputVector{2}) < 0)
            h = msgbox('Invalid input. t2 must be positive number or "end". Try again.')
            inputBoolean = false;
            uiwait(h);
            continue
            
      elseif (~(str2num(inputVector{2}) > str2num(inputVector{1}))) || (str2num(inputVector{2}) > maxT)
            h = msgbox('Invalid input. t2 must be greater than t1 and less than length of the x-axis. Try again.')
            inputBoolean = false;
            uiwait(h);
            continue
      else
          t2 =  str2num(inputVector{2});
          
      end  
end


%Trim E vector to only steady state values. Do this for each E vector
t1 = t1(1);
t2 = t2(1);
ESteadyState = E(t1:t2);
TInputSteadyState = T1(t1:t2);

%Take the mean and standard deviation from the steady state values.
EMean = mean(ESteadyState);
EStd = std(ESteadyState);
TInputMean = mean(TInputSteadyState);

%create a row to be put in the matrix
row = [TInputMean, EMean, EStd];

%Create a matrix that is nx3.
%(n,1) is the flow rate
%(n,2) is the mean
%(n,3) is the standard deviation

%Checks if dataMatrix is empty. If so, it replaces it with the first row.
if isempty(dataFile)
    dataFile = row;
else
    %Vertically concatanates matrix. Basically adds the row to the end of it.
    dataFile = [dataFile; row];
end


%Asks the user if they are done inputting data. If they are done, it breaks
%this whole loop and graphs everything close all
mtitle = 'Would you like to input more data?';
choice = menu(mtitle,'YES','NO');
boolean = false;

if choice == 2
    boolean = true;
end

end

m
dataFile 

    if m == 1
        dataFile1 = dataFile;
    end
    if m == 2
        dataFile2 = dataFile;
    end
    if m == 3
        dataFile3 = dataFile;
    end
    if m == 4
        dataFile4 = dataFile;
    end


%row = [TInputMean, EMean, EStd];

end

%After the loop completes, i.e. all the desired data has been input, graph
%the the effectiveness vs. flow rate, using std dev for error bars.
close all
hold on

plot(dataFile1(:,1), dataFile1(:,2), 'r.');
plot(dataFile2(:,1), dataFile2(:,2), 'r.');
plot(dataFile1(:,1), dataFile1(:,2), 'r.');
plot(dataFile1(:,1), dataFile1(:,2), 'r.');

errorbar(dataFile1(:,1), dataFile1(:,2), dataFile1(:,3), 'r.', 'MarkerSize', 25);
errorbar(dataFile2(:,1), dataFile2(:,2), dataFile2(:,3), 'g.', 'MarkerSize', 25);
errorbar(dataFile3(:,1), dataFile3(:,2), dataFile3(:,3), 'k.', 'MarkerSize', 25);
errorbar(dataFile4(:,1), dataFile4(:,2), dataFile4(:,3), 'c.', 'MarkerSize', 25);
set(gca,'FontSize',8)
title ('Effectiveness vs. Input Temperature', 'FontSize', 18);
xlabel('Input Temperature (C)', 'FontSize', 13);
ylabel ('E (q/q max)', 'FontSize', 13);
legend('2 ul/min', '5 ul/min', '10 ul/min', '100 ul/min');
