%% main_TSP_multi.m
% Birden fazla metasezgisel algoritmayi TSP uzerinde karsilastirma ornegi
% Algoritmalar:
%   GA  : Genetik Algoritma
%   PSO : Parcacik Suru Optimizasyonu
%   SA  : Simule Tavlama
%   TS  : Tabu Arama
%   ACO : Karinca Koloni Optimizasyonu
%   ABC : Yapay Ari Kolonisi
%
% Her algoritma icin:
%   - Convergence curve (en iyi maliyet vs iterasyon)
%   - Buldugu en iyi turun grafigi
%   - Calisma suresi olcumu
%
% NOT: CreateTSPInstance.m, TSPCost.m ve PlotTSPTour.m fonksiyonlari
% onceki mesajlardaki haliyle kullanilmistir.

clear; clc; close all;

%% 1. Problem boyutu (ayarlanabilir)
nCities = 5;          % Sehir sayisi buradan ayarlaniyor
seed    = 1;           % Tekrarlanabilirlik icin sabit tohum

problem = CreateTSPInstance(nCities, seed);

fprintf('Problem: %s, Sehir Sayisi: %d\n', problem.name, problem.nCities);

%% 2. Ortak parametreler
MaxIt = 200;           % Tum algoritmalar icin maksimum iterasyon

%% 3. Kullanilacak algoritma isimleri
algList = {'GA','PSO','SA','TS','ACO','ABC'};
nAlgs   = numel(algList);

% Sonuclar icin kayit degiskenleri
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

    % Parametre yapisi (tum algoritmalar icin MaxIt ortak)
    params.MaxIt = MaxIt;

    tic;    % sureyi baslat

    switch algo
        case 'GA'
            % GA parametreleri
            params.nPop     = 40;
            params.Pc       = 0.8;
            params.Pm       = 0.2;
            params.TourSize = 3;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = GA_TSP(problem, params);

        case 'PSO'
            % PSO parametreleri
            params.nPop = 40;
            params.w    = 0.7;
            params.c1   = 1.5;
            params.c2   = 1.5;
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = PSO_TSP(problem, params);

        case 'SA'
            % Simule tavlama parametreleri
            params.T0    = 1.0;   % ilk sicaklik
            params.alpha = 0.99;  % soguma katsayisi
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = SA_TSP(problem, params);

        case 'TS'
            % Tabu arama parametreleri
            params.TabuTenure   = 7;   % tabu suresi
            params.NeighSize    = 50;  % her iterasyonda denenecek swap sayisi
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = TS_TSP(problem, params);

        case 'ACO'
            % Karinca koloni parametreleri
            params.nAnts = 40;
            params.alpha = 1;     % feromon katsayisi
            params.beta  = 5;     % sezgisel bilgi katsayisi (1/mesafe)
            params.rho   = 0.5;   % buharlasma orani
            params.Q     = 100;   % feromon miktar katsayisi
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = ACO_TSP(problem, params);

        case 'ABC'
            % Yapay ari kolonisi parametreleri
            params.nFoodSources = 20;   % kaynak sayisi (koloni boyutu/2)
            params.Limit        = 20;   % ayni cozumu gelistirme limiti
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = ABC_TSP(problem, params);
    end

    RunTimes(a) = toc;   % sureyi kaydet

    fprintf('%s tamamlandi. En iyi maliyet = %.4f, Sure = %.4f sn\n', ...
        algo, BestCosts(a), RunTimes(a));

    % Her algoritmanin buldugu en iyi turu ciz
    figure('Name',['Best Tour - ' algo]);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur - Maliyet: %.2f, Sure: %.2f sn', algo, BestCosts(a), RunTimes(a)));
end

%% 5. Convergence curve karsilastirmasi
figure('Name','Convergence Curves - All Algorithms');
colors = lines(nAlgs);
for a = 1:nAlgs
    hist = BestCostHistory{a};
    plot(hist, 'Color', colors(a,:), 'LineWidth', 1.8); hold on;
end
grid on;
xlabel('Iterasyon');
ylabel('En Iyi Maliyet');
title('TSP - Convergence Curve Karsilastirmasi');
legend(algList, 'Location','best');

%% 6. Ozet tablo
resultsTable = table(algList', BestCosts, RunTimes, ...
    'VariableNames', {'Algorithm','BestCost','RunTime'});
disp(' ');
disp('==== Ozet Sonuclar ====');
disp(resultsTable);
