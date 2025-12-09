% de.m
% Differential Evolution (DE/rand/1/bin) - Gerçek kodlama

function [BestSol, BestCost, ConvergenceCurve] = de(problem, params)

    CostFunction = problem.CostFunction;
    nVar   = problem.nVar;
    VarMin = problem.VarMin;
    VarMax = problem.VarMax;

    % Parametreler (yoksa default ata)
    if ~isfield(params, 'MaxIt'), params.MaxIt = 200; end
    if ~isfield(params, 'nPop'),  params.nPop  = 30;  end
    if ~isfield(params, 'F'),     params.F     = 0.8; end
    if ~isfield(params, 'CR'),    params.CR    = 0.9; end

    MaxIt = params.MaxIt;
    nPop  = params.nPop;
    F     = params.F;    % Diferansiyel ağırlık
    CR    = params.CR;   % Çaprazlama oranı

    % Başlangıç popülasyonu
    pop = repmat(VarMin, nPop, 1) + ...
          rand(nPop, nVar) .* (VarMax - VarMin);
    cost = zeros(nPop,1);
    for i = 1:nPop
        cost(i) = CostFunction(pop(i,:));
    end

    % En iyi birey
    [BestCost, bestIdx] = min(cost);
    BestSol = pop(bestIdx,:);

    ConvergenceCurve = zeros(MaxIt,1);

    for it = 1:MaxIt
        for i = 1:nPop

            % 3 farklı indeks seç (i'den farklı)
            idxs = randperm(nPop, 3);
            while any(idxs == i)
                idxs = randperm(nPop, 3);
            end
            a = idxs(1); b = idxs(2); c = idxs(3);

            % Mutant vektör
            v = pop(a,:) + F*(pop(b,:) - pop(c,:));

            % Sınırla
            v = max(v, VarMin);
            v = min(v, VarMax);

            % Binomyal çaprazlama
            u = pop(i,:);
            jrand = randi(nVar);
            for j = 1:nVar
                if rand <= CR || j == jrand
                    u(j) = v(j);
                end
            end

            % Yeni maliyet
            newCost = CostFunction(u);

            % Greedy seçim
            if newCost <= cost(i)
                pop(i,:) = u;
                cost(i)  = newCost;

                % Global en iyi güncelle
                if newCost <= BestCost
                    BestCost = newCost;
                    BestSol  = u;
                end
            end
        end

        ConvergenceCurve(it) = BestCost;
        % fprintf('DE It=%d BestCost=%.4e\n', it, BestCost);
    end
end
