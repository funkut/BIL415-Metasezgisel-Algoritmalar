function [BestTour, BestCost, BestCostHistory] = ACO_TSP(problem, params)
% ACO_TSP
% TSP icin Karinca Koloni Optimizasyonu (Ant Colony Optimization)
%
% Girdi:
%   problem : TSP yapisi
%   params  : MaxIt, nAnts, alpha, beta, rho, Q
%
% Cikti:
%   BestTour        : En iyi tur
%   BestCost        : En iyi maliyet
%   BestCostHistory : Convergence curve

    nCities = problem.nCities;
    D  = problem.distMatrix;    % mesafe matrisi

    if ~isfield(params,'MaxIt'), params.MaxIt = 200; end
    if ~isfield(params,'nAnts'), params.nAnts = 40; end
    if ~isfield(params,'alpha'), params.alpha = 1;   end
    if ~isfield(params,'beta'),  params.beta  = 5;   end
    if ~isfield(params,'rho'),   params.rho   = 0.5; end
    if ~isfield(params,'Q'),     params.Q     = 100; end

    MaxIt = params.MaxIt;
    nAnts = params.nAnts;
    alpha = params.alpha;
    beta  = params.beta;
    rho   = params.rho;
    Q     = params.Q;

    % Sezgisel bilgi: 1 / mesafe
    eta = 1 ./ (D + eps);      % 0'a bolunme icin eps
    tau = ones(nCities);       % baslangicta tum kenarlarda ayni feromon

    BestCost = inf;
    BestTour = [];

    BestCostHistory = nan(MaxIt,1);

    for it = 1:MaxIt

        % Tum karincalarin cozumlerini saklayacagimiz yapi
        solutions(nAnts).tour = [];
        solutions(nAnts).cost = [];

        for k = 1:nAnts
            % Her karinca icin tur olustur
            tour = zeros(1,nCities);
            startCity = randi(nCities); % rastgele baslangic sehri
            tour(1) = startCity;

            visited = false(1,nCities);
            visited(startCity) = true;

            for step = 2:nCities
                i = tour(step-1);   % mevcut sehir

                % Gidilebilecek sehirler (henüz ziyaret edilmemiş)
                allowed = find(~visited);

                % Feromon ve sezgisel bilgi
                tau_i = tau(i,allowed);
                eta_i = eta(i,allowed);

                % Gecis olasiligi (tau^alpha * eta^beta)
                p = (tau_i.^alpha) .* (eta_i.^beta);
                p = p / sum(p);

                % Rulet tekerlegi secimi
                r = rand;
                cumP = cumsum(p);
                idx = find(r <= cumP,1,'first');
                j = allowed(idx);

                tour(step) = j;
                visited(j) = true;
            end

            % Tur maliyeti
            cost = TSPCost(tour, problem);

            solutions(k).tour = tour;
            solutions(k).cost = cost;

            % Global en iyi guncelle
            if cost < BestCost
                BestCost = cost;
                BestTour = tour;
            end
        end

        % Feromon buharlasma
        tau = (1 - rho) * tau;

        % Feromon ekleme (her karincanin turuna gore)
        for k = 1:nAnts
            tour = solutions(k).tour;
            cost = solutions(k).cost;
            tour = [tour tour(1)];   % turu kapat

            deltaTau = Q / cost;     % bu turun katkisi

            % Turdaki her kenara feromon ekle
            for s = 1:nCities
                i = tour(s);
                j = tour(s+1);
                tau(i,j) = tau(i,j) + deltaTau;
                tau(j,i) = tau(j,i) + deltaTau;
            end
        end

        BestCostHistory(it) = BestCost;
        fprintf('ACO It %3d: En Iyi Maliyet = %.4f\n', it, BestCostHistory(it));
    end
end
