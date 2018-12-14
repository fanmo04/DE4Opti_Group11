close all
clear
clc
%% Inputs into Solidworks
% All Input & output units:
% Length | mm , Width | mm ,Thickness | mm ,Curve Width | mm
% VMS | Pa , Disp | mm , Mass | g

% Latin hypercube sampling
p = 30 ;  % Points
N = 4  ; % Dimensions
% Lower Bounds
lb = [1 190 60 711]; % lower bounds for Length, Width, Thickness, curve width
ub = [15 222 170 812]; % upper bounds for Length, Width, Thickness, curve width
X = lhsdesign(p,N,'criterion', 'correlation') % criterion & correlation for equal distribution
InputLHS = bsxfun(@plus,lb,bsxfun(@times,X,(ub-lb))) %Apply element-wise operation to two arrays with implicit expansion enabled

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
