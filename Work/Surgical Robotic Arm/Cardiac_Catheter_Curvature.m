%Aristos Athens
%For work in Camarillo lab

%This is to find a polynomial fit for the St Jude Catheter's curvature

%The MAJOR assumption for this to work is that the line perpendicular to
%the start of the curved region is [1 0], i.e. the x-axis

clear all
close all

%% Data

%Catheter insertion table
%Column 1 is pixels per CENTIMETER
%Column 2 is the distance between base and inserter, in pixels
insertTable = [
    [1312-1202  2453-2245]
    [1254-1141  2280-2060]
    [1763-1659  1859-1603]
    [1819-1712  264]
    [105        289]
    [112        313]
    [110        319]
    [113        326]
    [83         249]
    ];

insertTable(:,1) = insertTable(:,1)/10;
insertDistance = insertTable(:,2)./insertTable(:,1);
insertDistance(:) = insertDistance(:) - insertDistance(1);

%Cather data table
%For each row:
%Column 1 is the how far the inserter has been pushed
%Column 2 value is the number of pixels per CENTIMETER
%Columns 3,4 values are the x,y value of the beginning of curvature
%Columns 5,6 values are the x,y value of the end of curavture
%Columns 7,8 values are the x,y value of the end of the tip.
dataTable = [
    [0  139  2233   1310   2347   576   2405   374]
    [0  141  2676   1217   2820   477   2892   272]
    [0  135  2679   1252   2896   570   3007   390]
    [0  118  2601   1239   2858   684   2985   561]
    [0  132  2442   1235   2872   753   3064   713]
    [0  147  2400   1115   2938   699   3152   736]
    [0  131  2438   1108   2957   873   3118   982]
    [0  151  2512   1387   3121   1266  3238   1454]
    [0  108  1892   813    2264   862   2263   1024]
     ];

%% Manipulate Data

%Put the insertDistances into column1 of the data table
dataTable(:,1) = insertDistance;
%Turn the pixel/cm values into pixel/mm
dataTable(:,2) = dataTable(:,2)/10;
%Turn all of the position data from pixels to mm
dataTable(:,3:8) = dataTable(:,3:8)./dataTable(:,2);

%Get vector representing the tip
tipVector = dataTable(:,7:8) - dataTable(:,5:6);
%Normalize tip vector to unit length
tipVector = tipVector/norm(tipVector);
%Creates a vector perpendicular to tipVector
perpTipVector = [ tipVector(:,2) -tipVector(:,1) ];

%If we assume the base (non-curving) part of the catheter is point straight
%upwards, then it will be pointing straight downwards with Gimp's
%coordinates.
%The non-curving part has direction vector [0 -1]
%Therefore the right-pointing vector perpendicular to this is:
perpStartVector = [-1; 0];

%Get the angle between perpTipVector and perpStartVector
%Use the following formula to get the angle between two 2d vectors
angle = acos(perpTipVector*perpStartVector/(norm(perpStartVector)*norm(perpTipVector)));

%This returns the coefficients for a 2-degree polynomial. Input is distance
%pushed, output is angle of curvature
p = polyfit(dataTable(:,1),angle(:),2);

%Radians
%Polynomial is Theta(d) = (-0.013)d^2 + (0.0646)d + 1.9797
curvature = p(1)*insertDistance.^2 + p(2)*insertDistance + p(3);

%% Plots

figure
plot(dataTable(:,1),curvature,dataTable(:,1),angle);
title("Measured vs Calculated Angle of Curvature vs. Insertion Distance");
legend("Calculated with polynomial", "Calculated from Images");
xlabel("Distance inserted (mm)");
ylabel("Angle of Curvature (radians)");