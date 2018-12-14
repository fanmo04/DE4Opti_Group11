function [Minimum, SQP, GlobalSQP, IP, GlobalIP] = optimisfunction( C, Y ,M, VMS, Displacement)

%%  Inputs 
% cost, material yield, [M1 M2 M3 M4 M5], [V1 V2], [D1 D2] 

% Cost ; cost of material per kilogram, number
% Material yield ; in N/mm^2 , number
% M ; Matrix of 4 numbers, the coefficients for the mass equation
% V ; Matrix 2 numbers, coefficients of VMS equation
% D ; Matrix of 2 numbers, coefficients of displacement equation
global D V Yield Cost 
D = Displacement ;
V = VMS ;
Yield = Y ;
Cost = C ;


%% Explanation of objectives & constraints

% x(1)| thickness
% x(2)| width
% x(3)| curve width
% x(4)| length

% Minimise f(x) = costperkg.*(M1*x(1)+ M2*x(2)+ M3*x(3) + M4*x(4))./100

% Linear Constraints
% g1 = 0 < mass < 500
% g1 = M2*x(1)+ M3*x(2)+ M4*x(3) + M5*x(4) + M1 < 500
% g2 = - M2*x(1) - M3*x(2)- M4*x(3) - M5*x(4) + M1 < 0
% g2 = 2.*x(3) - x(4) < - 400  

% Non Linear Constraints
% g3 = displacement - 2.1 < 0 
% g3 = D(1).*x(4).^3)./(x(2).*x(1).^3) + D(2) - 2.1 < 0
% g4 = VMS - 2*Yield < 0
% g4 = V(1).*x(4).^2)./(x(2).*x(1).^2) + V(2) - 2.*Yield < 0 

 
%% Optimisation
% Use Sequential Quadratic Programming to solve 
objective = @(x) Cost.*(M(2).*x(1) + M(3).*x(2) + M(4).*x(3) + M(5).*x(4) + M(1))./100; 

%Variable bounds
lb = [2 190 60 711]; 
ub = [15 222 170 812];

%Randomised initial starting point, ranomd seed so it is repeatable
rng(0,'twister');
x0 = (ub-lb).*rand(1,1)+ lb

%Show initial objective & initial cost
disp(['Initial Objective:' num2str(objective(x0))]) ; 
Cost_Initial = (M(2)*x0(1)+ M(3)*x0(2)+ M(4)*x0(3) + M(5)*x0(4) + M(1))*Cost

% linear constraints
A = [0, 0, 2, -1]; %active wrt x3
b = [ - 400 ] ;
Aeq = [];
beq = [];

% nonlinear constraints
nonlincon = @nlcon;
nvars = 4 ;

options = optimoptions('fmincon','Algorithm', 'interior-point');
options2 = optimoptions('fmincon','Algorithm', 'sqp');

% show final objective for Internal Points
IP = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,@nlcon,options);
disp(['Final Objective IP: ' num2str(objective(IP))])
Mass = M(2)*IP(1)+ M(3)*IP(2)+ M(4)*IP(3) + M(5)*IP(4) + M(1);
CostIP = (Mass.*Cost)./100; 
IP = [IP,Mass, CostIP];

%Create global search for SQP
problem = createOptimProblem('fmincon',...
    'objective',objective, ...
    'x0',x0,'Aineq',A,'bineq', b,'Aeq', Aeq,'beq', beq, 'lb',lb, 'ub', ub,'nonlcon', @nlcon, 'options',...
    optimoptions(@fmincon,'Algorithm','interior-point','Display','off'));

[x,fval] = fmincon(problem);
rng(40,'twister') 
gs = GlobalSearch('Display','iter');
[Global,fval] = run(gs,problem) ; 
MassGlobalIP = M(2)*x(1)+ M(3)*x(2)+ M(4)*x(3) + M(5)*x(4) + M(1) ;
CostGlobalIP = (MassGlobalIP.*Cost)./100 ;
disp(['Final Objective IP Global Search: ' num2str(objective(Global))])
GlobalIP = [Global,MassGlobalIP, CostGlobalIP] ; 

%Show final objective for SQP
SQP = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,@nlcon,options2);
Mass = M(2)*SQP(1)+ M(3)*SQP(2)+ M(4)*SQP(3) + M(5)*SQP(4) + M(1);
CostS = (Mass.*Cost)./100; 
SQP = [SQP,Mass, CostS];
disp(['Final Objective SQP: ' num2str(objective(SQP))])
% show final objective

%Create global search for SQP
problem = createOptimProblem('fmincon',...
    'objective',objective, ...
    'x0',x0,'Aineq',A,'bineq', b,'Aeq', Aeq,'beq', beq, 'lb',lb, 'ub', ub,'nonlcon', @nlcon, 'options',...
    optimoptions(@fmincon,'Algorithm','SQP','Display','off'));

%problem.lb = -Inf([2,1]);
[x,fval] = fmincon(problem);
rng(40,'twister') % for reproducibility
gs = GlobalSearch('Display','iter');
[Global,fval] = run(gs,problem) ; 
MassGlobalSQP = M(2)*x(1)+ M(3)*x(2)+ M(4)*x(3) + M(5)*x(4) + M(1) ;
CostGlobalSQP = (MassGlobalSQP.*Cost)./100 ;
disp(['Final Objective SQP: ' num2str(objective(Global))])
GlobalSQP = [Global,MassGlobalSQP, CostGlobalSQP] ; 

[M, I] = min([CostIP,CostGlobalIP, CostS, CostGlobalSQP]) ;
val = [IP; GlobalIP; SQP; GlobalSQP] ;
Minimum = val(I,:);

function [c, ceq] = nlcon(x)
   c(1) = (D(1)./(x(:,2).*x(:,1).^2) + D(2).*x(:,4) + D(3).*x(:,3) + D(4) - 2.1); % active w.r.t x1
   c(2) = (V(1))./(x(:,1).*x(:,2)) + V(2).*x(:,4) + V(3).*x(:,3) + V(4) - 2.*Yield  ;
   %c = []
   ceq = [] ; 
end
end


