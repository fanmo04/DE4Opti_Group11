clear all
clc
tic;
% total weight
W = (100 + 3)*9.81;
%C = 3*1260*V; % volume from solidworks
L = W/4; % load on one wheel

% Latin Hypercube Sampling
% variables: W, D, a, fillet
lb = [30 47 0 0];        % lower bound
ub = [70 100 24.23 8];        % upper bound
n = 30;                          % number of samples
p = 4;                          % number of parameters
xn = lhsdesign(n,p);            % generate normalized design
sample = bsxfun(@plus,lb,bsxfun(@times,xn,(ub-lb)))

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
% VMS(N/m^2) Diplacement(mm) strain volume(mm3)
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
volume = Output(:,4);

%Shuffling the Dataset with random seed
rng(1);                                 % MATLAB random seed 1
newInd = randperm(length(Output));  % New index order for data sets

Input_New = Input(newInd,:);     % Shuffled Input
Output_New = Output(newInd,:);      % Shuffled Output  

% SPLIT DATA SETS (75%-25% RULE) & NORMALIZE WRT TRAINING SET
split_point = floor(0.75*length(Output));  % Round down using floor

%Normalisation of Training Data using mapstd
[Input_newTrain1,PS_InpTrain1] = mapstd(Input_New(1:split_point,:)');
[Output_newTrain1,PS_OutTrain1] = mapstd(Output_New(1:split_point,:)');


%Normalisation of Test Data using mapstd
Input_newTest1 = mapstd('apply',Input_New(split_point+1:end,:)',PS_InpTrain1) ;
Output_newTest1 = mapstd('apply',Output_New(split_point+1:end,:)',PS_OutTrain1) ;

Input_NewTrainT = Input_newTrain1' ;
Output_NewTrainT = Output_newTrain1'; 
Input_NewTestT = Input_newTest1';
Output_NewTestT = Output_newTest1';


beta = mvregress(Input_NewTrainT, Output_NewTrainT);
betaVMS = beta(:,1);
betaD = beta(:,2);
betavolume = beta(:,4);

% Try linear regression model
input_set = [Input_newTrain1,Input_newTest1]'
width_new = input_set(:,1);
diameter_new = input_set(:,2);
angle_new = input_set(:,3);
fillet_new = input_set(:,4);
volume_coloumn = [Output_newTrain1(4,:),Output_newTest1(4,:)]'
tbl = table(width_new,diameter_new,angle_new,fillet_new,volume_coloumn);
linear_mdl = fitlm(tbl);
linear_r2 = linear_mdl.Rsquared.Adjusted

% Plot residuals versus the fitted values
figure
plot(linear_mdl)
figure
plotResiduals(linear_mdl,'fitted')    

% calculate R square values
Rsq = 1 - norm(Input_newTest1'*beta - Output_newTest1')^2/norm(Output_newTest1-mean(Input_newTest1))^2;

RsqVMS = 1 - norm(Input_NewTestT*betaVMS - Output_NewTestT(:,1))^2/norm(Output_newTest1(1,:)-mean(Input_newTest1))^2;
RsqD = 1 - norm(Input_NewTestT*betaD - Output_NewTestT(:,2))^2/norm(Output_newTest1(2,:)-mean(Input_newTest1))^2;
Rsqvolume = 1 - norm(Input_NewTestT*betavolume - Output_NewTestT(:,4))^2/norm(Output_newTest1(4,:)-mean(Input_newTest1))^2;

% Use Ploynomial fit, with dimension of 2
p1 = polyfitn(Input,volume,2)
% Show the polynomial model of input - volume
polymodel_volume = polyn2sym(p1)


nonlcon = @confuneq;
functionOptim = matlabFunction(polymodel_volume);
fun = @(x)x(1).*(-4.869416919044358e-3)-x(2).*3.929727471190939e-3+x(3).*5.384406971021096e-3+x(4).*2.133033657937706e-3+x(1).*x(2).*1.228056204384904e-4+x(1).*x(3).*5.373586540637725e-6-x(1).*x(4).*1.994084757325977e-5-x(2).*x(3).*9.730643593782969e-5-x(2).*x(4).*1.307676644403529e-5-x(3).*x(4).*7.523676947936464e-5+x(1).^2.*1.293309260264071e-6+x(2).^2.*2.592786129390755e-5-x(3).^2.*8.713404546934495e-6-x(4).^2.*7.727204914222017e-5+1.420207691067759e-1;

% fmincon
options = optimoptions(@fmincon,'Algorithm','sqp');
x1 = [33.61   99.25   9.48   6.32];
x2 = [69.85   82.16   6.81   7.26];
x3 = [55.25   78.95   11.0   3.01];
x4 = [42.68   78.24   14.3   1.74];
x_fmincon1 = fmincon(fun,x1,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_fmincon2 = fmincon(fun,x2,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_fmincon3 = fmincon(fun,x3,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_fmincon4 = fmincon(fun,x4,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon,options);
x_list = [x_fmincon1;x_fmincon2;x_fmincon3;x_fmincon4]
predicted1 = polyvaln(p1,x_fmincon1)
predicted2 = polyvaln(p1,x_fmincon2)
predicted3 = polyvaln(p1,x_fmincon3)
predicted4 = polyvaln(p1,x_fmincon4)
original1 = polyvaln(p1,x1)

x_ga1 = ga(fun,4,[],[],[],[],[30 47 0 0], [70 100 24.23 8],nonlcon)

%annelx1= [ 49.47   96.02   8.72   5.31]
%[a,fvala,exitFlaga,outputa] = simulannealbnd(fun,annelx1,[30 47 0 0], [70 100 24.23 8])
%[b,fvalb,exitFlagb,outputb] = simulannealbnd(fun,x2,[30 47 0 0], [70 100 24.23 8])
%[c,fvalc,exitFlagc,outputc] = simulannealbnd(fun,x3,[30 47 0 0], [70 100 24.23 8]);
%annealingout = [a;b;c]
toc;

function [c,ceq] = confuneq(x);
c = 2*tand(x(3))*(x(2)/2-11)-x(1)+15;
ceq = [];
end

