function [model] = buildQMKP(areas, transports, n, m, cap)
%% Name variables
x = cell(n, m);
for i = 1:m
    for j = 1:n
        x{j,i} = sprintf('x%d_%d',j,i);
    end
end
names = x(:); % variables must be in vector form

model.varnames = names;
%% Build quadratic objective matrix Q: x'*Q*x
QSmall = transports;
QSmallHalf = triu(QSmall+QSmall',1);
QSmallFull = QSmallHalf' + QSmallHalf;
Q = kron(eye(m),QSmallFull); % Kronecker Product (replicate Matrix)

model.Q = sparse(Q/2);
%% Linear Constraints: A*x <= b
AArea = kron(eye(m),areas'); % linear area constraint matrix (expanded)
bArea = cap*ones(m,1)'; % linear area constraint vector
AAssignLimitBlock = diag(ones(1,n)); % each OR is to be assigned to exactly 
% one floor

% formulate each equality constraint as a set of two inequality constraints
AAssignLimit = repmat(AAssignLimitBlock,1,m);
Aeq = AAssignLimit;
Aineq1 = Aeq; 
Aineq2 = -Aeq;
A = [AArea; Aineq1; Aineq2];

beq = ones(n,1)';
bineq1 = beq;
bineq2 = -beq;
b = [bArea, bineq1, bineq2];

model.A = sparse(A);
model.rhs = b;
%% Nonlinear constraints x'*Qc*x = bc
% OR i and j are to be placed on the same floor
[~,~,~,~,~,groupORs,posLay] = loadInput();

if ~isempty(groupORs{1})
    Qc = cell(size(groupORs,2)-1,1);
    for i = 1:size(groupORs,2)-1
        AGroupBlock = zeros(n);
        AGroupBlock(groupORs{i}(1),groupORs{i}(2)) = 1;
        AGroupBlock(groupORs{i}(2),groupORs{i}(1)) = 1;
        Qc{i} = kron(eye(m),AGroupBlock);

        model.quadcon(i).Qc = sparse(Qc{i});
        model.quadcon(i).q = zeros(n*m,1);
        model.quadcon(i).rhs = 2;
        model.quadcon(i).sense = '=';
    end

    % make sure corresponding ORs are not placed on the same floor if top 
    % and bottom floor constraints are specified
    if posLay(1)*posLay(2)~=0
        AGroupBlock(groupORs{end}(1),groupORs{end}(2)) = 1;
        AGroupBlock(groupORs{end}(2),groupORs{end}(1)) = 1;
        Qc{end+1} = kron(eye(m),AGroupBlock);
        model.quadcon(end+1).Qc = sparse(Qc{end});
        model.quadcon(end+1).q = zeros(n*m,1);
        model.quadcon(end+1).rhs = 0;
        model.quadcon(end+1).sense = '=';
    end
end
%% additional model parameters
model.sense = '<'; % sense of inequality constraints
model.vtype = 'B'; % variables are binary
model.modelsense = 'max'; % maximize result
end

