function [model] = buildQAP(transports, n, resultMatCompact)
%% Name variables
x = cell(n);
for i = 1:n
    for j = 1:n
        x{j,i} = sprintf('y%d_%d',j,i);
    end
end
names = x(:); % variables must be in vector form

model.varnames = names;
%% Build quadratic objective matrix Q: x'*Q*x
D = toeplitz(1:n); % build transport matrix
D = D-ones(size(D));
% e = transports.*(ones(n)-eye(n)); % matrix block
Q = kron(D,transports); % Expanded transport intensity matrix
% 
model.Q = sparse(Q);
% model.Q = sparse(kron(e,D));
%% Linear equality constraints: A*x = b
[~,~,~,~,~,~,posLay] = loadInput();
A1 = kron(eye(n),ones(1,n)); % exactly one floor per position
A2 = kron(ones(1,n),eye(n)); % exactly one position per floor

% Constraints for placing specific floor at the top and/or bottom
if posLay(2)~=0
    floor = find(resultMatCompact(posLay(2),:));
    ASetBot = zeros(1,n^2);
    ASetBot(floor) = 1;
else
    ASetBot=[];
end
if posLay(1)~=0
    floor = find(resultMatCompact(posLay(1),:));    
    ASetTop = zeros(1,n^2);
    ASetTop(ASetTop(end+1-n+floor)) = 1;
else
    ASetTop=[];
end

% combine matrices and vectors and set model parameters
A = [A1; A2; ASetBot; ASetTop];
b = ones(size(A,1),1);
model.A = sparse(A);
model.rhs = b;

%% additional model parameters
model.sense = '='; % equality constraints
model.vtype = 'B'; % variables are binary
model.modelsense = 'min'; % minimize result
end

