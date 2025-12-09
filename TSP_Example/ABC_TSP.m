function [BestTour, BestCost, BestCostHistory] = ABC_TSP(problem, params)
% ABC_TSP
% TSP icin Yapay Ari Kolonisi (Artificial Bee Colony) algoritmasi
%
% Girdi:
%   problem : TSP yapisi
%   params  : MaxIt, nFoodSources, Limit
%
% Cikti:
%   BestTour        : En iyi tur
%   BestCost        : En iyi maliyet
%   BestCostHistory : Convergence curve

    nCities = problem.nCities;

    if ~isfield(params,'MaxIt'),         params.MaxIt         = 200; end
    if ~isfield(params,'nFoodSources'),  params.nFoodSources  = 20;  end
    if ~isfield(params,'Limit'),         params.Limit         = 20;  end

    MaxIt        = params.MaxIt;
    nFood        = params.nFoodSources;
    Limit        = params.Limit;

    % Her kaynak icin:
    %   - Position: tur (perm.)
    %   - Cost    : maliyet
    %   - Trials  : gelismezse artan sayac
    food(nFood).Position = [];
    food(nFood).Cost     = [];
    food(nFood).Trials   = 0;

    % Baslangic kaynaklari
    for i = 1:nFood
        food(i).Position = randperm(nCities);
        food(i).Cost     = TSPCost(food(i).Position, problem);
        food(i).Trials   = 0;
    end

    % En iyi cozum
    [BestCost, idx] = min([food.Cost]);
    BestTour = food(idx).Position;

    BestCostHistory = nan(MaxIt,1);

    for it = 1:MaxIt

        %% 1. Employed bees fazi
        for i = 1:nFood
            % Rastgele baska bir kaynak sec
            k = randi(nFood);
            while k == i
                k = randi(nFood);
            end

            % Mevcut cozumu al
            currentTour = food(i).Position;
            neighborTour = currentTour;

            % Basit komsu: swap + belki ikinci swap
            neighborTour = SwapMutation(neighborTour);

            newCost = TSPCost(neighborTour, problem);

            % Iyi ise kabul et, Trials sifirlanir
            if newCost < food(i).Cost
                food(i).Position = neighborTour;
                food(i).Cost     = newCost;
                food(i).Trials   = 0;
            else
                food(i).Trials   = food(i).Trials + 1;
            end
        end

        %% 2. Fitness hesapla (onlooker icin olasilik)
        costs   = [food.Cost];
        % Fitness: daha kucuk cost, daha buyuk fitness
        fitness = 1 ./ (1 + costs);
        prob    = fitness / sum(fitness);

        %% 3. Onlooker bees fazi
        nOnlookers = nFood;   % basit: ayni sayida onlooker
        for t = 1:nOnlookers
            % Rulet tekerlegi ile kaynak sec
            i = RouletteWheelSelection(prob);

            % Rastgele baska kaynak
            k = randi(nFood);
            while k == i
                k = randi(nFood);
            end

            currentTour  = food(i).Position;
            neighborTour = currentTour;
            neighborTour = SwapMutation(neighborTour);

            newCost = TSPCost(neighborTour, problem);

            if newCost < food(i).Cost
                food(i).Position = neighborTour;
                food(i).Cost     = newCost;
                food(i).Trials   = 0;
            else
                food(i).Trials   = food(i).Trials + 1;
            end
        end

        %% 4. Scout fazi (Limit'i asanlar yeniden baslatilir)
        for i = 1:nFood
            if food(i).Trials >= Limit
                food(i).Position = randperm(nCities);
                food(i).Cost     = TSPCost(food(i).Position, problem);
                food(i).Trials   = 0;
            end
        end

        %% 5. Global en iyi guncelle
        [iterBestCost, idx] = min([food.Cost]);
        iterBestTour = food(idx).Position;

        if iterBestCost < BestCost
            BestCost = iterBestCost;
            BestTour = iterBestTour;
        end

        BestCostHistory(it) = BestCost;
        fprintf('ABC It %3d: En Iyi Maliyet = %.4f\n', it, BestCostHistory(it));
    end
end

%% --- Yardimci fonksiyonlar ---
function p_new = SwapMutation(p)
    n = numel(p);
    i = randi(n);
    j = randi(n);
    while j == i
        j = randi(n);
    end
    p_new = p;
    p_new([i j]) = p_new([j i]);
end

function idx = RouletteWheelSelection(p)
    r = rand;
    c = cumsum(p);
    idx = find(r <= c, 1, 'first');
end
