clear variables; close all; clc;
addpath (genpath ( pwd )); % recursively add all subdirectories to path
%% load input
[areas, transports, params] = loadInput();
n = size(areas,1); % number of ORs
[m,cap] = buildFramework(areas);
%% Subproblem 1
% build QMKP (quadratic multiple knapsack problem) model
QMKP = buildQMKP(areas, transports, n, m, cap);

% Assign ORs to floors (solve QMKP)
gurobi_write(QMKP, 'mip1.lp');

result1 = gurobi(QMKP, params);

% display results
disp(result1);
for v=1:length(QMKP.varnames)
    fprintf('%s %d\n', QMKP.varnames{v}, result1.x(v));
end

% transform results into matrix form
resultMat = zeros(n,m);
l = 0;
for j = 1:m
    for i = 1:n
        l = l+1;
        resultMat(i,j) = round(result1.x(l));
    end
end
resultMatCompact = resultMat;
resultMatCompact(:,~any(resultMat,1)) = []; % remove zero columns
%% Subproblem 2
% merge transports for floors
transportsMerged = resultMat'*transports*resultMat;
indR = find(all(transportsMerged==0,2)); %Find indices of zero rows
indC = find(all(transportsMerged==0,1)); %Find indices of zero columns
% delete floors with no input AND output
indMerged = [indR' indC];
U = unique(indMerged);
ind = U(1<histc(indMerged,unique(indMerged)));
transportsMerged(:,ind) = []; % remove zero rows
transportsMerged(ind,:) = []; % remove zero columns

mAct = length(transportsMerged(1,:)); % number of active floors

% build QAP (quadratic assignment problem) model
QAP = buildQAP(transportsMerged, mAct, resultMatCompact);

% solve QAP
gurobi_write(QAP, 'mip1.lp');

result2 = gurobi(QAP, params);
disp(result2);
for v=1:length(QAP.varnames)
    fprintf('%s %d\n', QAP.varnames{v}, result2.x(v));
end
%% print output
csvwrite('results/OR_assignments.csv',resultMatCompact);

k = 1;
QAPMat = zeros(mAct,2);
for i = 1:mAct % goal floor index
    for j = 1:mAct % initial floor index
        if result2.x(k) == 1
            QAPMat(i,1) = j;
            QAPMat(i,2) = i;
        end
        k = k+1;
    end
end

InitialFloor = QAPMat(:,1);
TargetFloor = QAPMat(:,2);
T = table(InitialFloor, TargetFloor);
writetable(T,'results/floor_order.csv');
