%% main_TSP_cityCargo.m
% GERCEK DUNYA SENARYOSU 1:
% Sehir ici kargo dagitim rotasi
%
% Sehir 1  : Depo / Merkez
% Sehir 2..n : Musteri teslimat noktaları
%
% Amac: Depodan cik, tum musterileri 1 kez ziyaret et, depoya don.
%       Toplam yol uzunlugunu en aza indiren rotayi bul.

clear; clc; close all;

%% 1. Problem boyutu (ayarlanabilir)
nCustomers = 25;        % Musteri sayisi
nCities    = nCustomers + 1;  % 1 depo + musteriler

seed = 10;              % Tekrarlanabilirlik icin tohum

% Rastgele TSP problemi olustur (simdi depoyu 1. sehir sayacagiz)
problem = CreateTSPInstance(nCities, seed);

% Problem adini daha gercekci yapalim
problem.name = sprintf('Sehir Ici Kargo Dagitimi (1 Depo + %d Musteri)', nCustomers);

fprintf('Problem: %s, Toplam Nokta: %d (1 depo + %d musteri)\n', ...
    problem.name, problem.nCities, nCustomers);

%% 2. Ortak parametreler (tum algoritmalar icin)
MaxIt = 200;           % Maksimum iterasyon sayisi

%% 3. Karsilastirilacak algoritmalar
algList = {'GA','PSO','SA','TS','ACO','ABC'};
nAlgs   = numel(algList);

BestTours        = cell(nAlgs,1);
BestCosts        = zeros(nAlgs,1);
BestCostHistory  = cell(nAlgs,1);
RunTimes         = zeros(nAlgs,1);

%% 4. Algoritmalari sirayla calistir
for a = 1:nAlgs
    algo = algList{a};
    fprintf('\n=============================\n');
    fprintf('Algoritma: %s\n', algo);
    fprintf('=============================\n');

    % Ortak parametre yapisi
    params.MaxIt = MaxIt;

    tic;  % sureyi baslat

    switch algo
        case 'GA'
            params.nPop     = 40;
            params.Pc       = 0.8;
            params.Pm       = 0.2;
            params.TourSize = 3;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = GA_TSP(problem, params);

        case 'PSO'
            params.nPop = 40;
            params.w    = 0.7;
            params.c1   = 1.5;
            params.c2   = 1.5;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = PSO_TSP(problem, params);

        case 'SA'
            params.T0    = 1.0;
            params.alpha = 0.99;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = SA_TSP(problem, params);

        case 'TS'
            params.TabuTenure = 7;
            params.NeighSize  = 50;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = TS_TSP(problem, params);

        case 'ACO'
            params.nAnts = 40;
            params.alpha = 1;
            params.beta  = 5;
            params.rho   = 0.5;
            params.Q     = 100;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = ACO_TSP(problem, params);

        case 'ABC'
            params.nFoodSources = 20;
            params.Limit        = 20;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = ABC_TSP(problem, params);
    end

    RunTimes(a) = toc;  % calisma süresi

    fprintf('%s tamamlandi. En iyi maliyet = %.4f, Sure = %.4f sn\n', ...
        algo, BestCosts(a), RunTimes(a));

    % En iyi turu ciz (sehir 1: depo, digerleri: musteriler)
    figure('Name',['Best Tour - ' algo ' (City Cargo)']);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur - Maliyet: %.2f, Sure: %.2f sn', ...
        algo, BestCosts(a), RunTimes(a)));
end

%% 5. Convergence curve karsilastirmasi
figure('Name','Convergence Curves - City Cargo');
colors = lines(nAlgs);
for a = 1:nAlgs
    hist = BestCostHistory{a};
    plot(hist, 'Color', colors(a,:), 'LineWidth', 1.8); hold on;
end
grid on;
xlabel('Iterasyon');
ylabel('En Iyi Maliyet');
title('Sehir Ici Kargo Dagitimi - Convergence Curve');
legend(algList, 'Location','best');

%% 6. Ozet tablo
resultsTable = table(algList', BestCosts, RunTimes, ...
    'VariableNames', {'Algorithm','BestCost','RunTime'});

disp(' ');
disp('==== Sehir Ici Kargo Dagitimi - Ozet Sonuclar ====');
disp(resultsTable);
