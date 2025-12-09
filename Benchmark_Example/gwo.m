% gwo.m
% Grey Wolf Optimizer (Gri Kurt Optimizasyonu)

function [BestSol, BestCost, ConvergenceCurve] = gwo(problem, params)

    CostFunction = problem.CostFunction;
    nVar   = problem.nVar;
    VarMin = problem.VarMin;
    VarMax = problem.VarMax;

    MaxIt = params.MaxIt;
    nPop  = params.nPop;

    % Popülasyon (kurtlar)
    pos = VarMin + (VarMax-VarMin).*rand(nPop, nVar);
    cost = zeros(nPop, 1);

    for i = 1:nPop
        cost(i) = CostFunction(pos(i,:));
    end

    % Alpha, Beta, Delta kurtları
    [sortedCost, sortIdx] = sort(cost);
    Alpha.Position = pos(sortIdx(1), :);
    Alpha.Cost     = sortedCost(1);

    Beta.Position  = pos(sortIdx(2), :);
    Beta.Cost      = sortedCost(2);

    Delta.Position = pos(sortIdx(3), :);
    Delta.Cost     = sortedCost(3);

    ConvergenceCurve = zeros(MaxIt, 1);

    % Ana döngü
    for it = 1:MaxIt
        a = 2 - 2*it/MaxIt;   % a lineer olarak 2'den 0'a iner
        
        for i = 1:nPop
            for j = 1:nVar
                r1 = rand; r2 = rand;
                A1 = 2*a*r1 - a;
                C1 = 2*r2;
                
                D_alpha = abs(C1*Alpha.Position(j) - pos(i,j));
                X1 = Alpha.Position(j) - A1*D_alpha;

                r1 = rand; r2 = rand;
                A2 = 2*a*r1 - a;
                C2 = 2*r2;

                D_beta = abs(C2*Beta.Position(j) - pos(i,j));
                X2 = Beta.Position(j) - A2*D_beta;

                r1 = rand; r2 = rand;
                A3 = 2*a*r1 - a;
                C3 = 2*r2;

                D_delta = abs(C3*Delta.Position(j) - pos(i,j));
                X3 = Delta.Position(j) - A3*D_delta;

                % Yeni konum: üç liderin ortalaması
                pos(i,j) = (X1 + X2 + X3) / 3;
            end

            % Sınırlar
            pos(i,:) = max(pos(i,:), VarMin);
            pos(i,:) = min(pos(i,:), VarMax);

            % Yeni maliyet
            cost(i) = CostFunction(pos(i,:));
        end

        % Alpha, Beta, Delta güncelle
        [sortedCost, sortIdx] = sort(cost);
        if sortedCost(1) < Alpha.Cost
            Alpha.Position = pos(sortIdx(1), :);
            Alpha.Cost     = sortedCost(1);
        end
        
        if sortedCost(2) < Beta.Cost
            Beta.Position  = pos(sortIdx(2), :);
            Beta.Cost      = sortedCost(2);
        end
        
        if sortedCost(3) < Delta.Cost
            Delta.Position = pos(sortIdx(3), :);
            Delta.Cost     = sortedCost(3);
        end

        ConvergenceCurve(it) = Alpha.Cost;
        % fprintf('GWO It=%d BestCost=%.4e\n', it, Alpha.Cost);
    end

    BestSol  = Alpha.Position;
    BestCost = Alpha.Cost;
end
