%% main_TSP_campusShuttle.m
% GERCEK DUNYA SENARYOSU 2:
% Universite Kampusu Ring Servisi
%
% Her nokta: kampus icindeki önemli bir bina / durak
% Ornek:
%   1: Rektorluk
%   2: Muhendislik Fakultesi
%   3: IIBF
%   4: Kutuphane
%   5: Merkezi Yemekhane
%   6: Yurtlar
%   7: Spor Salonu
%   8: Arastirma Merkezi
%
% Amaç: Ring servisi tum duraklara ugrasın, baslangic duragina geri donsun,
%       toplam mesafeyi (gezi süresini) minimize etsin.

clear; clc; close all;

%% 1. Kampus noktalarini (koordinatlarini) tanimla
% Koordinatlar: [x y], keyfi birim (kampus krokisini andiracak sekilde)
% Burayi istersen kendi kampus haritana gore duzenleyebilirsin.

stopNames = {
    'Rektorluk';          % 1
    'Muhendislik';        % 2
    'IIBF';               % 3
    'Kutuphane';          % 4
    'Yemekhane';          % 5
    'Yurtlar';            % 6
    'Spor Salonu';        % 7
    'Arastirma Merkezi'   % 8
    };

coords = [...
    10 50;   % 1: Rektorluk
    25 60;   % 2: Muhendislik
    40 55;   % 3: IIBF
    35 40;   % 4: Kutuphane
    20 35;   % 5: Yemekhane
    5  30;   % 6: Yurtlar
    30 20;   % 7: Spor Salonu
    50 30];  % 8: Arastirma Merkezi

nCities = size(coords,1);

% Mesafe matrisini hesapla
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
problem.name       = 'Kampus Ring Servisi TSP';

fprintf('Problem: %s, Durak Sayisi: %d\n', problem.name, problem.nCities);

%% 2. Ortak parametreler
MaxIt = 200;   % iterasyon sayisi (gerektiginde degistirilebilir)

%% 3. Algoritma listesi
algList = {'GA','PSO','SA','TS','ACO','ABC'};
nAlgs   = numel(algList);

BestTours        = cell(nAlgs,1);
BestCosts        = zeros(nAlgs,1);
BestCostHistory  = cell(nAlgs,1);
RunTimes         = zeros(nAlgs,1);

%% 4. Algoritmalari calistirma
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

    % En iyi turu ciz (durak isimlerini de gosterelim)
    figure('Name',['Best Tour - ' algo ' (Campus Shuttle)']);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur - Maliyet: %.2f, Sure: %.2f sn', ...
        algo, BestCosts(a), RunTimes(a)));

    % Durak isimlerini komut penceresinde goster (istege bagli)
    bestTour = BestTours{a};
    fprintf('> %s icin en iyi rota (durak sirasi):\n', algo);
    for k = 1:length(bestTour)
        idx = bestTour(k);
        fprintf('%2d: %s\n', idx, stopNames{idx});
    end
    fprintf('\n');
end

%% 5. Convergence curve
figure('Name','Convergence Curves - Campus Shuttle');
colors = lines(nAlgs);
for a = 1:nAlgs
    hist = BestCostHistory{a};
    plot(hist, 'Color', colors(a,:), 'LineWidth', 1.8); hold on;
end
grid on;
xlabel('Iterasyon');
ylabel('En Iyi Maliyet');
title('Kampus Ring Servisi - Convergence Curve');
legend(algList, 'Location','best');

%% 6. Ozet tablo
resultsTable = table(algList', BestCosts, RunTimes, ...
    'VariableNames', {'Algorithm','BestCost','RunTime'});

disp(' ');
disp('==== Kampus Ring Servisi - Ozet Sonuclar ====');
disp(resultsTable);
