%% Completing Linear Regression
%Shuffling the Dataset with random seed

function [mdlM, betaVMS, betaDisp] = linearfunction(Input, Output)
rng(1);                                 % MATLAB random seed 1
newInd = randperm(length(Output));  % New index order for data sets

Input_New = Input(newInd,:);     % Shuffled Input
Output_New = Output(newInd,:);      % Shuffled Output  

% SPLIT DATA SETS (75%-25% RULE) & NORMALIZE WRT TRAINING SET
split_point = floor(0.75*length(Output));  % Round down using floor

%Do not need to normlise data as it is already of the same magnitude
Input_NewTrainT = Input_New(1:split_point,:)
Output_NewTrainT = Output_New(1:split_point,:); 
Input_NewTestT = Input_New(split_point+1:end,:) ;
Output_NewTestT = Output_New(split_point+1:end,:) ;

%Linear regression for Mass
betaMass = mvregress(Input_NewTrainT, Output_NewTrainT(:,3))  
RsqM = 1 - norm(Input_NewTestT*betaMass - Output_NewTestT(:,3))^2/norm(Output_NewTestT(:,3)'-mean(Input_NewTestT)')^2 
mdlM = fitlm(Input_NewTrainT,Output_NewTrainT(:,3))
%High R^2 so can be used

%Linear regression for VMS
%Low R^2 so further improvement required
betaVMS = mvregress(Input_NewTrainT, Output_NewTrainT(:,1))
RsqVMS = 1 - norm(Input_NewTestT*betaVMS - Output_NewTestT(:,1))^2/norm(Output_NewTestT(:,1)'-mean(Input_NewTestT)')^2 ;

%Linear regression for displacement
%Low r^2 so further improvement needed
betaDisp = mvregress(Input_NewTrainT, Output_NewTrainT(:,2)) ;
RsqDisp = 1 - norm(Input_NewTestT*betaDisp - Output_NewTestT(:,2))^2/norm(Output_NewTestT(:,2)'-mean(Input_NewTestT)')^2 ;
end 
