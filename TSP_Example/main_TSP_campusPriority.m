%% main_TSP_campusPriority.m
% GERCEK DUNYA SENARYOSU:
% Oncelikli Kampus Ring Seferi (Priority TSP)
%
% Duraklar (ornek):
%   1: Ring Baslangic / Merkez
%   2: Hastane
%   3: Guvenlik Merkezi
%   4: Rektorluk
%   5: Muhendislik Fakultesi
%   6: IIBF
%   7: Kutuphane
%   8: Yurtlar
%   9: Spor Salonu
%
% Oncelik ornegi:
%   - (1) En yuksek: Hastane, Guvenlik, Rektorluk
%   - (2) Orta    : Fakulteler, Kutuphane
%   - (3) Dusuk   : Yurtlar, Spor Salonu
%
% Amaç:
%   - Hem toplam mesafe kisa olsun
%   - Hem de oncelikli binalara, daha az onceliklilerden once gidilsin.
%   - Oncelik ihlali olursa TSPCost icinde ceza geliyor.

clear; clc; close all;

%% 1. Durak isimleri ve koordinatlar (kolayca degistirilebilir)

stopNames = {
    'Ring Merkezi';      % 1
    'Hastane';           % 2
    'Guvenlik Merkezi';  % 3
    'Rektorluk';         % 4
    'Muhendislik';       % 5
    'IIBF';              % 6
    'Kutuphane';         % 7
    'Yurtlar';           % 8
    'Spor Salonu';       % 9
};

% [x y] koordinatlar (kampus krokisine benzetebilirsin)
coords = [...
    10 10;   % 1: Ring Merkezi
    40 20;   % 2: Hastane
    5  35;   % 3: Guvenlik Merkezi
    20 40;   % 4: Rektorluk
    30 30;   % 5: Muhendislik
    25 20;   % 6: IIBF
    15 25;   % 7: Kutuphane
    10 45;   % 8: Yurtlar
    35 10];  % 9: Spor Salonu

nCities = size(coords,1);

%% 2. Oncelik vektoru (1 = en yuksek, 3 = dusuk)
% Burayi sadece sayilari degistirerek senaryoyu oynayabilirsin.

priority = [...
    2;   % 1: Ring Merkezi (orta)
    1;   % 2: Hastane (en yuksek)
    1;   % 3: Guvenlik (en yuksek)
    1;   % 4: Rektorluk (en yuksek)
    2;   % 5: Muhendislik (orta)
    2;   % 6: IIBF (orta)
    2;   % 7: Kutuphane (orta)
    3;   % 8: Yurtlar (dusuk)
    3];  % 9: Spor Salonu (dusuk)

% Ceza katsayisi (ne kadar buyuk olursa, oncelik ihlalinden o kadar kacilir)
priorityPenalty = 1000;   % deneyerek ayarlanabilir

%% 3. Mesafe matrisi olustur
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

%% 4. Problem struct'i
problem.nCities          = nCities;
problem.coords           = coords;
problem.distMatrix       = distMatrix;
problem.name             = 'Oncelikli Kampus Ring TSP';
problem.priority         = priority;         % oncelik vektoru eklendi
problem.priorityPenalty  = priorityPenalty;  % ceza katsayisi

fprintf('Problem: %s, Durak Sayisi: %d\n', problem.name, problem.nCities);

%% 5. Ortak parametreler
MaxIt = 200;   % iterasyon sayisi (gerektiginde degistir)

%% 6. Kullanilacak algoritmalar
algList = {'GA','PSO','SA','TS','ACO','ABC'};
nAlgs   = numel(algList);

BestTours        = cell(nAlgs,1);
BestCosts        = zeros(nAlgs,1);
BestCostHistory  = cell(nAlgs,1);
RunTimes         = zeros(nAlgs,1);

%% 7. Algoritmalari calistir
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

    fprintf('%s tamamlandi. (Mesafe + Oncelik cezali) En iyi maliyet = %.4f, Sure = %.4f sn\n', ...
        algo, BestCosts(a), RunTimes(a));

    % En iyi turu ciz
    figure('Name',['Best Tour - ' algo ' (Campus Priority)']);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur (Cezali Maliyet): %.2f, Sure: %.2f sn', ...
        algo, BestCosts(a), RunTimes(a)));

    % En iyi rotayi isimlerle komut penceresine yaz
    bestTour = BestTours{a};
    fprintf('> %s icin en iyi rota (sira ile):\n', algo);
    for k = 1:length(bestTour)
        idx = bestTour(k);
        fprintf('%2d (P=%d): %s\n', idx, priority(idx), stopNames{idx});
    end
    fprintf('\n');
end

%% 8. Convergence curve karsilastirmasi
figure('Name','Convergence Curves - Campus Priority');
colors = lines(nAlgs);
for a = 1:nAlgs
    hist = BestCostHistory{a};
    plot(hist, 'Color', colors(a,:), 'LineWidth', 1.8); hold on;
end
grid on;
xlabel('Iterasyon');
ylabel('En Iyi (Mesafe + Ceza) Maliyeti');
title('Oncelikli Kampus Ring TSP - Convergence Curves');
legend(algList, 'Location','best');

%% 9. Ozet tablo
resultsTable = table(algList', BestCosts, RunTimes, ...
    'VariableNames', {'Algorithm','BestCost_Penalized','RunTime'});

disp(' ');
disp('==== Oncelikli Kampus Ring - Ozet Sonuclar (Mesafe + Ceza) ====');
disp(resultsTable);
