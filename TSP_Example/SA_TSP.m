function [BestTour, BestCost, BestCostHistory] = SA_TSP(problem, params)
% SA_TSP
% TSP icin Simule Tavlama (Simulated Annealing)
%
% Girdi:
%   problem : TSP yapisi
%   params  : MaxIt, T0, alpha
%
% Cikti:
%   BestTour        : En iyi bulunan tur
%   BestCost        : En iyi maliyet
%   BestCostHistory : Convergence curve

    nCities = problem.nCities;

    if ~isfield(params,'MaxIt'), params.MaxIt = 200; end
    if ~isfield(params,'T0'),    params.T0    = 1.0; end
    if ~isfield(params,'alpha'), params.alpha = 0.99; end

    MaxIt = params.MaxIt;
    T0    = params.T0;
    alpha = params.alpha;

    % Baslangic cozumu: rasgele tur
    currentTour = randperm(nCities);
    currentCost = TSPCost(currentTour, problem);

    BestTour = currentTour;
    BestCost = currentCost;

    T = T0;  % baslangic sicakligi

    BestCostHistory = nan(MaxIt,1);

    for it = 1:MaxIt

        % Komsu cozum uret (swap mutasyon)
        newTour = SwapMutation(currentTour);
        newCost = TSPCost(newTour, problem);

        % Maliyet farki
        delta = newCost - currentCost;

        if delta <= 0
            % Daha iyi cozum ise her zaman kabul
            currentTour = newTour;
            currentCost = newCost;
        else
            % Daha kotu cozum: olasilikla kabul (Metropolis kriteri)
            p = exp(-delta / T);
            if rand <= p
                currentTour = newTour;
                currentCost = newCost;
            end
        end

        % Global en iyi guncelle
        if currentCost < BestCost
            BestCost = currentCost;
            BestTour = currentTour;
        end

        % Sicakligi azalt
        T = T * alpha;

        BestCostHistory(it) = BestCost;
        fprintf('SA  It %3d: En Iyi Maliyet = %.4f, T = %.4f\n', it, BestCostHistory(it), T);
    end
end

%% --- Basit swap mutasyonu ---
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
