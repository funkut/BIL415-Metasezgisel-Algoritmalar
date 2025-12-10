function [BestTour, BestCost, BestCostHistory] = TS_TSP(problem, params)
% TS_TSP
% TSP icin Tabu Arama algoritmasi
%
% Basit versiyon:
%   - Komşuluk: swap(i,j) hareketleri
%   - Tabu listesi: belli sure icin (i,j) swap tabu
%
% Girdi:
%   problem : TSP yapisi
%   params  : MaxIt, TabuTenure, NeighSize
%
% Cikti:
%   BestTour        : En iyi tur
%   BestCost        : En iyi maliyet
%   BestCostHistory : Convergence curve

    nCities = problem.nCities;

    if ~isfield(params,'MaxIt'),       params.MaxIt       = 200; end
    if ~isfield(params,'TabuTenure'),  params.TabuTenure  = 7;   end
    if ~isfield(params,'NeighSize'),   params.NeighSize   = 50;  end

    MaxIt      = params.MaxIt;
    TabuTenure = params.TabuTenure;
    NeighSize  = params.NeighSize;

    % Baslangic turu: rasgele
    currentTour = randperm(nCities);
    currentCost = TSPCost(currentTour, problem);

    BestTour = currentTour;
    BestCost = currentCost;

    % Tabu listesi: swap(i,j) icin tabu suresi
    tabu = zeros(nCities, nCities);

    BestCostHistory = nan(MaxIt,1);

    for it = 1:MaxIt

        bestNeighborTour = [];
        bestNeighborCost = inf;
        bestSwap = [0 0];

        % Belirli sayida komsuluk hareketi incele (NeighSize kadar)
        for k = 1:NeighSize
            % Rastgele iki sehir sec
            i = randi(nCities);
            j = randi(nCities);
            while j == i
                j = randi(nCities);
            end
            if i > j   % (i,j) siralama
                tmp = i; i = j; j = tmp;
            end

            % Swap uygula -> komsu tur
            newTour = currentTour;
            newTour([i j]) = newTour([j i]);
            newCost = TSPCost(newTour, problem);

            % Tabu kontrolu
            isTabu = tabu(i,j) > 0;
            % Aspiration kriteri: eger global en iyiden iyiyse tabu olsa bile kabul
            if (isTabu && newCost < BestCost) || ~isTabu
                % Bu komsu simdiye kadar en iyiyse kaydet
                if newCost < bestNeighborCost
                    bestNeighborCost = newCost;
                    bestNeighborTour = newTour;
                    bestSwap = [i j];
                end
            end
        end

        % Eger hic komsu bulunamazsa (teorik olarak zor ama), rastgele swap yap
        if isempty(bestNeighborTour)
            bestNeighborTour = SwapMutation(currentTour);
            bestNeighborCost = TSPCost(bestNeighborTour, problem);
            bestSwap = [1 2];  % dummy
        end

        % Tabu suresini azalt
        tabu = max(tabu - 1, 0);

        % En iyi komsuya gecerken ilgili swap'i tabu yap
        i = bestSwap(1); j = bestSwap(2);
        tabu(i,j) = TabuTenure;
        tabu(j,i) = TabuTenure;

        % Komsu cozum yeni current olur
        currentTour = bestNeighborTour;
        currentCost = bestNeighborCost;

        % Global en iyiyi guncelle
        if currentCost < BestCost
            BestCost = currentCost;
            BestTour = currentTour;
        end

        BestCostHistory(it) = BestCost;
        fprintf('TS  It %3d: En Iyi Maliyet = %.4f\n', it, BestCostHistory(it));
    end
end

%% --- Swap mutasyonu (yedek) ---
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
