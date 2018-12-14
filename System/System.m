close all
clear
clc
tic;
%% Inputs into Solidworks
% All Input & output units:
% Length | mm , Width | mm ,Thickness | mm ,Curve Width | mm
% VMS | Pa , Disp | mm , Mass | g



%% Load input and output data from Solidworks meta model
load 'Input30'
load 'Ply30'
load 'Al30'
load 'ABS30'
load 'PET30'
load 'CF30'

%format: [thickness width curvewidth length]
Input = double(Input30) ;

% format: [VMS Displacement Mass]
Plywood = double(Ply30) ;
ABS = double(ABS30) ; 
Aluminium = double(Al30) ;
PET = double(PET30) ;
CF = double(CF30) ; 

%Cost data
%[Ply ABS Al PET CF]
Cost = [0.4 0.73 1 8.73 157] ;

%Material yield data
%[Ply ABS Al PET CF]
Yield = [1.38E+7 3E+7 6.8E+7 8.4E+7 2.3E+7 ]

%% Create Meta Model

% Non linear testing:
[PlyMass, PlyVMS, PlyDisp] = linearfunction(Input, Plywood); 
[ABSMass, ABSVMS, ABSDisp] = linearfunction(Input, ABS);
[AlMass, AlVMS, AlDisp] = linearfunction(Input, Aluminium);
[CFMass, CFVMS, CFDisp] = linearfunction(Input, CF);
[PETMass, PETVMS, PETDisp] = linearfunction(Input, PET);

[PlyD, PlyVMS] = nonlinearfunction(Input, Plywood, Yield(1));
[ABSD, ABSVMS] = nonlinearfunction(Input, ABS, Yield(2));
[AlD, AlVMS] = nonlinearfunction(Input, Aluminium, Yield(3));
[CFD, CFVMS] = nonlinearfunction(Input, CF, Yield(4));
[PETD, PETVMS] = nonlinearfunction(Input, PET, Yield(5));

%% Optimisation of materials
[MinPly, SQPPly, SQPGPly, IPPly, GIPPly] = optimisfunction( Cost(1), Yield(1), table2array(PlyMass.Coefficients(:,1)), table2array(PlyVMS.Coefficients(:,1)), table2array(PlyD.Coefficients(:,1)));
[MinABS,SQPABS, SQPGABS, IPABS, GIPABS] = optimisfunction( Cost(2), Yield(2),  table2array(ABSMass.Coefficients(:,1)), table2array(ABSVMS.Coefficients(:,1)), table2array(ABSD.Coefficients(:,1)));
[MinAl,SQPAl, SQPGAl, IPAl, GIPAl] = optimisfunction( Cost(3), Yield(3), table2array(AlMass.Coefficients(:,1)), table2array(AlVMS.Coefficients(:,1)), table2array(AlD.Coefficients(:,1)));
[MinCF, SQPCF, SQPGCF, IPCF, GIPCF] = optimisfunction( Cost(4), Yield(4), table2array(CFMass.Coefficients(:,1)), table2array(CFVMS.Coefficients(:,1)), table2array(CFD.Coefficients(:,1)));
[MinPET, SQPPET, SQPGPET, IPPET, GIPPET] = optimisfunction( Cost(5), Yield(5),table2array(PETMass.Coefficients(:,1)), table2array(PETVMS.Coefficients(:,1)), table2array(PETD.Coefficients(:,1)));

%% Displaying solution
disp('Solution for Plywood')
disp(['Cost = ' num2str(MinPly(6))])
disp(['Mass =' num2str(MinPly(5))])
disp(['Measurements =' num2str(MinPly(1:4))])
disp('Solution for ABS')
disp(['Cost = ' num2str(MinABS(6))])
disp(['Mass =' num2str(MinABS(5))])
disp(['Measurements =' num2str(MinABS(1:4))])
disp('Solution for Aluminium')
disp(['Cost = ' num2str(MinAl(6))])
disp(['Mass =' num2str(MinAl(5))])
disp(['Measurements =' num2str(MinAl(1:4))])
disp('Solution for Carbon Fibre')
disp(['Cost = ' num2str(MinCF(6))])
disp(['Mass =' num2str(MinCF(5))])
disp(['Measurements =' num2str(MinCF(1:4))])
disp('Solution for PET')
disp(['Cost = ' num2str(MinPET(6))])
disp(['Mass =' num2str(MinPET(5))])
disp(['Measurements =' num2str(MinPET(1:4))])



% data points from Latin Hypercube sampling
% variables: W, D, a, fillet
Input =[
    60.97   95.72   6.86    0
    41.85   73.34   16.2   6.63
    33.61   99.25   9.48   6.32
    57.20   68.81   1.29   7.92
    52.95   59.35   12.0   2.23
    
    51.38   65.16   20.9   7.56
    40.09   53.13   8.33   0.01
    45.07   68.00   13.4   3.22
    67.66   49.42   16.2   1.04
    61.42   75.04   1.07   2.07
    
    55.79   90.93   2.61   5.40
    69.85   82.16   6.81   7.26
    36.75   57.35   0.13   3.54
    64.42   55.54   18.8   7.97
    62.98   92.59   22.5   0.51
    
    58.27   97.67   14.9   6.75
    42.68   78.24   14.3   1.74
    59.64   60.75   17.0   4.21
    49.47   96.02   8.72   5.31
    38.97   70.16   11.9   2.18
    
    47.28   63.42   16.1   5.82
    65.10   88.42   21.4   4.76
    34.76   48.44   5.20   1.42
    48.06   51.93   10.0   6.96
    31.85   83.96   14.3   0.93
    
    55.25   78.95   11.0   3.01
    30.91   75.78   2.06   2.89
    66.30   86.65   3.35   4.81
    43.74   85.31   4.38   0.66
    36.50   94.41   13.8   4.35
    ];

W = Input(:,1);
D = Input(:,2);
a = Input(:,3);
fillet = Input(:,4);

% Outputs taken from the Solidworks simulation 
% VMS(N/m^2) Diplacement(mm) strain mass(mm3)
Output = [
    919000  0.0043  0.00030 0.404
    2540000 0.0094  0.00080 0.134
    5299000 0.0160  0.00157 0.205
    762800  0.0038  0.00025 0.198
    1038000 0.0045  0.00033 0.121
    
    1539000 0.0063  0.00046 0.128
    1465000 0.0053  0.00046 0.077
    1598000 0.0063  0.00050 0.137
    664200  0.0027  0.00021 0.114
    700800  0.0034  0.00023 0.262
    
    870100  0.0049  0.00028 0.342
    662400  0.0035  0.00020 0.338
    1398000 0.0056  0.00043 0.087
    845700  0.0037  0.00026 0.121
    1605000 0.0064  0.00053 0.333
    
    1413000 0.0061  0.00042 0.356
    2274000 0.0084  0.00071 0.167
    959700  0.0039  0.00031 0.146
    1395000 0.0063  0.00044 0.312
    2116000 0.0081  0.00062 0.125
    
    1546000 0.0060  0.00048 0.119
    1346000 0.0055  0.00040 0.317
    1644000 0.0060  0.00050 0.055
    1105000 0.0045  0.00033 0.084
    14810000 0.032  0.00378 0.132
    
    1105000 0.0048  0.00034 0.238
    2252000 0.0089  0.00070 0.128
    685500  0.0036  0.00022 0.370
    1323000 0.0059  0.00039 0.231
    6526000 0.0187  0.00201 0.192
    ];

VMS = Output(:,1);
Displacement = Output(:,2);
mass = Output(:,4);

% Use Ploynomial fit, with dimension of 2
p1 = polyfitn(Input,mass,2)

% Show the polynomial model of input - mass
polymodel_mass = polyn2sym(p1)

% nonlinear inequality constraint
nonlcon = @confuneq;
functionOptim = matlabFunction(polymodel_mass);
fun = @(x)x(1).*(-4.869416919044358e-3)-x(2).*3.929727471190939e-3+x(3).*5.384406971021096e-3+x(4).*2.133033657937706e-3+x(1).*x(2).*1.228056204384904e-4+x(1).*x(3).*5.373586540637725e-6-x(1).*x(4).*1.994084757325977e-5-x(2).*x(3).*9.730643593782969e-5-x(2).*x(4).*1.307676644403529e-5-x(3).*x(4).*7.523676947936464e-5+x(1).^2.*1.293309260264071e-6+x(2).^2.*2.592786129390755e-5-x(3).^2.*8.713404546934495e-6-x(4).^2.*7.727204914222017e-5+1.420207691067759e-1;

% fmincon + sqp
options = optimoptions(@fmincon,'Algorithm','sqp');
x1 = [33.61   99.25   9.48   6.32];
x2 = [69.85   82.16   6.81   7.26];
x3 = [55.25   78.95   11.0   3.01];
x4 = [42.68   78.24   14.3   1.74];
x_fmincon1 = fmincon(fun,x1,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_fmincon2 = fmincon(fun,x2,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_fmincon3 = fmincon(fun,x3,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_fmincon4 = fmincon(fun,x4,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_list = [x_fmincon1;x_fmincon2;x_fmincon3;x_fmincon4];
mass1 = polyvaln(p1,x_fmincon1)*1.26
MinCost_sub1 = MinPly(:,6)
MinCost_sub2 = 4.*mass1.*6;

Total_Mincost = MinCost_sub1 + MinCost_sub2

toc;

function [c,ceq] = confuneq(x);
c = 2*tand(x(3))*(x(2)/2-11)-x(1)+15;
ceq = [];
end

