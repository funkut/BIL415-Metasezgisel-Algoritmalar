%% main_TSP_warehousePicking.m
% GERCEK DUNYA SENARYOSU 3:
% E-ticaret deposu icinde siparis toplama (order picking) rotasi
%
% Noktalar:
%   1 : Toplama/Paketleme istasyonu (depo cikisi)
%   2..n : Siparisteki urunlerin bulundugu raf lokasyonlari
%
% Amaç: Istasyondan cik, tum raflara 1 kez ugrayip urunleri topla,
%       tekrar istasyona don. Toplam yurumeyi (mesafeyi) minimize et.

clear; clc; close all;

%% 1. Depo yerlesimi (raf koordinatlari)
% Basit bir grid/depo krokisi tanimliyoruz.
% Birimi "metre" ya da "adim" gibi dusunebilirsin.

% 1: Packing station (giris/cikis)
% 2..N: Raf lokasyonlari (A1, A2, B1, B2, ... gibi)
%
% Istersen bunlari kendi depona gore degistirebilirsin.
coords = [...
    0   0;   % 1: Packing station (depo girisi)
    5   5;   % 2: Raf A1
    5  15;   % 3: Raf A2
    5  25;   % 4: Raf A3
    15  5;   % 5: Raf B1
    15 15;   % 6: Raf B2
    15 25;   % 7: Raf B3
    25  5;   % 8: Raf C1
    25 15;   % 9: Raf C2
    25 25;   %10: Raf C3
    35 10;   %11: Raf D1
    35 20];  %12: Raf D2

% Istersen sadece belirli sayida raf kullanmak icin:
% nPickLocations = 10;  % ornegin ilk 10 nokta
% coords = coords(1:nPickLocations,:);

nCities = size(coords,1);

% Raf isimleri (rapor icin)
stopNames = {
    'Packing Station';    % 1
    'Raf A1';             % 2
    'Raf A2';             % 3
    'Raf A3';             % 4
    'Raf B1';             % 5
    'Raf B2';             % 6
    'Raf B3';             % 7
    'Raf C1';             % 8
    'Raf C2';             % 9
    'Raf C3';             %10
    'Raf D1';             %11
    'Raf D2';             %12
    };

%% 2. Mesafe matrisini olustur (TSP icin)
distMatrix = zeros(nCities, nCities);
for i = 1:nCities
    for j = 1:nCities
        if i == j
            distMatrix(i,j) = 0;
        else
            dx = coords(i,1) - coords(j,1);
            dy = coords(i,2) - coords(j,2);
            distMatrix(i,j) = sqrt(dx^2 + dy^2);  % Öklid mesafe
        end
    end
end

% TSP problem struct'i
problem.nCities    = nCities;
problem.coords     = coords;
problem.distMatrix = distMatrix;
problem.name       = 'Depo Icinde Siparis Toplama TSP';

fprintf('Problem: %s, Nokta Sayisi: %d (1 istasyon + %d raf)\n', ...
    problem.name, problem.nCities, problem.nCities-1);

%% 3. Ortak parametreler
MaxIt = 200;   % Tum algoritmalar icin iterasyon sayisi

%% 4. Algoritma listesi
algList = {'GA','PSO','SA','TS','ACO','ABC'};
nAlgs   = numel(algList);

BestTours        = cell(nAlgs,1);
BestCosts        = zeros(nAlgs,1);
BestCostHistory  = cell(nAlgs,1);
RunTimes         = zeros(nAlgs,1);

%% 5. Algoritmalari calistir
for a = 1:nAlgs
    algo = algList{a};
    fprintf('\n=============================\n');
    fprintf('Algoritma: %s\n', algo);
    fprintf('=============================\n');

    params.MaxIt = MaxIt;
    tic;

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

    RunTimes(a) = toc;

    fprintf('%s tamamlandi. En iyi maliyet = %.4f, Sure = %.4f sn\n', ...
        algo, BestCosts(a), RunTimes(a));

    % En iyi turu ciz
    figure('Name',['Best Tour - ' algo ' (Warehouse Picking)']);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur - Maliyet: %.2f, Sure: %.2f sn', ...
        algo, BestCosts(a), RunTimes(a)));

    % Rota uzerindeki raf isimlerini komut penceresine yaz
    bestTour = BestTours{a};
    fprintf('> %s icin en iyi rota (sira ile):\n', algo);
    for k = 1:length(bestTour)
        idx = bestTour(k);
        fprintf('%2d: %s\n', idx, stopNames{idx});
    end
    fprintf('\n');
end

%% 6. Convergence curve karsilastirmasi
figure('Name','Convergence Curves - Warehouse Picking');
colors = lines(nAlgs);
for a = 1:nAlgs
    hist = BestCostHistory{a};
    plot(hist, 'Color', colors(a,:), 'LineWidth', 1.8); hold on;
end
grid on;
xlabel('Iterasyon');
ylabel('En Iyi Maliyet');
title('Depo Icinde Siparis Toplama - Convergence Curve');
legend(algList, 'Location','best');

%% 7. Ozet tablo
resultsTable = table(algList', BestCosts, RunTimes, ...
    'VariableNames', {'Algorithm','BestCost','RunTime'});

disp(' ');
disp('==== Depo Siparis Toplama - Ozet Sonuclar ====');
disp(resultsTable);
