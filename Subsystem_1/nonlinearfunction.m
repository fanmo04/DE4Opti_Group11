%% Completing Linear Regression


function [mdlD, mdlVMS] = nonlinearfunction(Input, Output, VMS)
rng(1);                                 % MATLAB random seed 1
newInd = randperm(length(Output));  % New index order for data sets

Input_New = Input(newInd,:);     % Shuffled Input
Output_New = Output(newInd,:);      % Shuffled Output  

% SPLIT DATA SETS (75%-25% RULE) & NORMALIZE WRT TRAINING SET
split_point = floor(0.75*length(Output));  % Round down using floor


Input_NewTrainT = Input_New(1:split_point,:);
Output_NewTrainT = Output_New(1:split_point,:); 
Input_NewTestT = Input_New(split_point+1:end,:) ;
Output_NewTestT = Output_New(split_point+1:end,:) ;

beta0 = [1 1 1 1]

%% Subsystem -  Model for displacement
modelfun2 = @(b,x)(b(:,1)./(x(:,2).*x(:,1).^2) +b(2).*x(:,4) + b(3).*x(:,3) + b(4))
mdlD = fitnlm(Input_NewTrainT, Output_NewTrainT(:,2), modelfun2,beta0) 
[mdlD.RMSE min(Output(:,2)) max(Output(:,2))]
%% Uncomment to see the residuals of the model
%plotResiduals(mdlD)
%figure
%plotDiagnostics(mdlD,'cookd')
%figure
Output_NewTrainT(:,2)
ypred = feval(mdlD, Input_NewTestT)
[Input_NewTestTh, t] = sort(Input_NewTestT(:,1)) ;
ypred = ypred(t);
Output_NewTestD2 = Output_NewTestT(t,2)  ;
scatter(Output_NewTestD2, Input_NewTestTh);
hold on
plot(ypred, Input_NewTestTh) ;
hold off
xlabel('Thickness (mm)')
ylabel('Displacement (mm)')
figure

%% VMS 
modelfun1 = @(b,x)(b(:,1)./(x(:,1).*x(:,2))+ b(2).*x(:,4) + b(3).*x(:,3)+b(4));
mdlVMS = fitnlm(Input_NewTrainT, Output_NewTrainT(:,1), modelfun1,beta0);
[mdlVMS.RMSE min(Output(:,1)) max(Output(:,1))];
%plotResiduals(mdlVMS);
%figure
%plotDiagnostics(mdlVMS,'cookd');
ypred = feval(mdlVMS, Input_NewTestT);
ypred = ypred(t);
scatter(Output_NewTestT(t,1), Input_NewTestTh(:,1));
xlabel('Thickness (mm)')
ylabel('VMS(N/mm^2)')
hold on
plot(ypred, Input_NewTestTh) ;
hold off
figure
end 
