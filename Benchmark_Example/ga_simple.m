% ga_simple.m
% Basit gerçek değerli Genetik Algoritma (GA)

function [BestSol, BestCost, ConvergenceCurve] = ga_simple(problem, params)

    CostFunction = problem.CostFunction;
    nVar   = problem.nVar;
    VarMin = problem.VarMin;
    VarMax = problem.VarMax;

    % Parametreler (yoksa default ata)
    if ~isfield(params, 'MaxIt'), params.MaxIt = 100; end
    if ~isfield(params, 'nPop'),  params.nPop  = 40;  end
    if ~isfield(params, 'pc'),    params.pc    = 0.7; end  % crossover oranı
    if ~isfield(params, 'pm'),    params.pm    = 0.1; end  % mutation oranı
    if ~isfield(params, 'mu'),    params.mu    = 0.1; end  % mutation step (sigma)
    if ~isfield(params, 'beta'),  params.beta  = 1;   end  % selection pressure

    MaxIt = params.MaxIt;
    nPop  = params.nPop;
    pc    = params.pc;
    pm    = params.pm;
    mu    = params.mu;
    beta  = params.beta;

    nCrossover = 2*round(pc*nPop/2);   % çift sayı
    nMutation  = round(pm*nPop);

    % Birey şablonu
    empty_ind.Position = [];
    empty_ind.Cost     = [];

    % Başlangıç popülasyonu
    pop = repmat(empty_ind, nPop, 1);
    for i = 1:nPop
        pop(i).Position = VarMin + (VarMax-VarMin).*rand(1,nVar);
        pop(i).Cost     = CostFunction(pop(i).Position);
    end

    % En iyi birey
    [BestCost, bestIdx] = min([pop.Cost]);
    BestSol = pop(bestIdx).Position;

    ConvergenceCurve = zeros(MaxIt,1);

    for it = 1:MaxIt

        % Uygunluk (fitness) hesapla (minimizasyonu maximizasyona çevirmek için)
        costs = [pop.Cost];
        avgCost = mean(costs);
        if avgCost ~= 0
            costs = costs/avgCost;
        end
        fitness = exp(-beta*costs);  % daha küçük cost -> daha büyük fitness
        fitness = fitness/sum(fitness);

        % --------- Crossover ---------
        popC = repmat(empty_ind, nCrossover, 1);
        for k = 1:2:nCrossover
            i1 = rouletteWheelSelection(fitness);
            i2 = rouletteWheelSelection(fitness);

            p1 = pop(i1);
            p2 = pop(i2);

            % Basit aritmetik crossover
            alpha = rand(1,nVar);
            c1.Position = alpha.*p1.Position + (1-alpha).*p2.Position;
            c2.Position = alpha.*p2.Position + (1-alpha).*p1.Position;

            c1.Position = max(c1.Position, VarMin);
            c1.Position = min(c1.Position, VarMax);
            c2.Position = max(c2.Position, VarMin);
            c2.Position = min(c2.Position, VarMax);

            c1.Cost = CostFunction(c1.Position);
            c2.Cost = CostFunction(c2.Position);

            popC(k)   = c1;
            popC(k+1) = c2;
        end

        % --------- Mutation ---------
        popM = repmat(empty_ind, nMutation, 1);
        for k = 1:nMutation
            i = randi(nPop);
            p = pop(i);

            % Gaussian mutation
            m.Position = p.Position + mu*randn(1,nVar).*(VarMax-VarMin);
            m.Position = max(m.Position, VarMin);
            m.Position = min(m.Position, VarMax);

            m.Cost = CostFunction(m.Position);
            popM(k) = m;
        end

        % Yeni popülasyonu birleştir
        popAll = [pop; popC; popM]; %#ok<AGROW>

        % Cost’a göre sırala
        [~, sortIdx] = sort([popAll.Cost]);
        popAll = popAll(sortIdx);

        % İlk nPop bireyi al
        pop = popAll(1:nPop);

        % En iyi birey güncelle
        [BestCost, bestIdx] = min([pop.Cost]);
        BestSol = pop(bestIdx).Position;

        ConvergenceCurve(it) = BestCost;
        % fprintf('GA It=%d BestCost=%.4e\n', it, BestCost);
    end
end

% ---------------- Yardımcı fonksiyon ----------------
function i = rouletteWheelSelection(P)
    r = rand;
    C = cumsum(P);
    i = find(r <= C, 1, 'first');
end
