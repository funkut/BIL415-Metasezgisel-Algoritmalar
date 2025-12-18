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

clear; clc; close all;

%% 1. Problem boyutu (ayarlanabilir)
nCities = 81;          % Sehir sayisini buradan degistirebilirsin
seed    = 1;           % Tekrarlanabilirlik icin sabit tohum

% Problem struct'ını oluştur
problem = CreateTSPInstance(nCities, seed);

fprintf('Problem: %s, Sehir Sayisi: %d\n', problem.name, problem.nCities);

%% 2. Ortak parametreler
MaxIt = 200;           % Tum algoritmalar icin maksimum iterasyon sayisi

%% 3. Karsilastirilacak algoritmalarin listesi
algList = {'GA','PSO','SA','TS','ACO','ABC'};
nAlgs   = numel(algList);

% Sonuclar icin kayit degiskenleri
BestTours        = cell(nAlgs,1);   % Her algoritmanin en iyi turu
BestCosts        = zeros(nAlgs,1);  % Her algoritmanin en iyi maliyeti
BestCostHistory  = cell(nAlgs,1);   % Her algoritmanin convergence curve'u
RunTimes         = zeros(nAlgs,1);  % Calisma sureleri

%% 4. Algoritmalari sirayla calistir
for a = 1:nAlgs
    algo = algList{a};   % su anki algoritma ismi
    fprintf('\n=============================\n');
    fprintf('Algoritma: %s\n', algo);
    fprintf('=============================\n');

    % Parametre yapisi (her seferinde MaxIt'i set et)
    params.MaxIt = MaxIt;

    % Sureyi baslat (tic/toc ile)
    tic;

    % Algoritmaya gore uygun fonksiyonu cagir
    switch algo
        case 'GA'
            % GA parametreleri
            params.nPop     = 40;   % populasyon boyutu
            params.Pc       = 0.8;  % crossover orani
            params.Pm       = 0.2;  % mutasyon orani
            params.TourSize = 3;    % turnuva boyutu
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = GA_TSP(problem, params);

        case 'PSO'
            % PSO parametreleri
            params.nPop = 40;    % parcacik sayisi
            params.w    = 0.7;   % atalet agirligi
            params.c1   = 1.5;   % bireysel (cognitive) katsayi
            params.c2   = 1.5;   % sosyal (social) katsayi
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = PSO_TSP(problem, params);

        case 'SA'
            % Simule tavlama parametreleri
            params.T0    = 1.0;   % ilk sicaklik
            params.alpha = 0.99;  % soguma oranı
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = SA_TSP(problem, params);

        case 'TS'
            % Tabu arama parametreleri
            params.TabuTenure   = 7;    % tabu suresi
            params.NeighSize    = 50;   % her iterasyonda bakilacak komsu sayisi
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = TS_TSP(problem, params);

        case 'ACO'
            % Karinca koloni parametreleri
            params.nAnts = 40;   % karinca sayisi
            params.alpha = 1;    % feromon katsayisi
            params.beta  = 5;    % sezgisel bilgi (1/d) katsayisi
            params.rho   = 0.5;  % feromon buharlasma orani
            params.Q     = 100;  % feromon miktar katsayisi
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = ACO_TSP(problem, params);

        case 'ABC'
            % Yapay ari kolonisi parametreleri
            params.nFoodSources = 20;   % kaynak sayisi
            params.Limit        = 20;   % gelismezse yenilenme limiti
            [BestTours{a}, BestCosts(a), BestCostHistory{a}] = ABC_TSP(problem, params);
    end

    % Gecen sureyi kaydet
    RunTimes(a) = toc;

    fprintf('%s tamamlandi. En iyi maliyet = %.4f, Sure = %.4f sn\n', ...
        algo, BestCosts(a), RunTimes(a));

    % Her algoritmanin buldugu en iyi turu ciz
    figure('Name',['Best Tour - ' algo]);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur - Maliyet: %.2f, Sure: %.2f sn', ...
        algo, BestCosts(a), RunTimes(a)));
end

%% 5. Convergence curve karsilastirmasi (hepsi tek grafikte)
figure('Name','Convergence Curves - All Algorithms');
colors = lines(nAlgs);   % otomatik renk paleti
for a = 1:nAlgs
    hist = BestCostHistory{a};      % ilgili algoritmanin tarihcesi
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
