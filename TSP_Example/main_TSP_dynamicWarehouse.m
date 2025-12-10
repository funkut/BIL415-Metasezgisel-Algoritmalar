%% main_TSP_dynamicWarehouse.m
% DİNAMİK GERÇEK DÜNYA SENARYOSU:
% E-ticaret deposunda sipariş toplama (order picking) TSP
%
% Bu main'de:
%   - Koordinatlar DİNAMİK olarak üretilebilir:
%       * 'grid'   : Izgara şeklinde raf yerleşimi (profesyonel depo)
%       * 'random' : Belirli alanda rastgele raf yerleşimi
%       * 'file'   : Koordinatlar dosyadan okunur (örneğin CSV/Excel)
%   - Mevcut TSP fonksiyonları kullanılır:
%       GA_TSP, PSO_TSP, SA_TSP, TS_TSP, ACO_TSP, ABC_TSP,
%       TSPCost, PlotTSPTour
%
% Not: Bu script'i calistirmadan once ilgili fonksiyonlar ayni klasorde olmali.

clear; clc; close all;

%% ==== 1. SENARYO PARAMETRELERİ ====

% Koordinat üretim modu: 'grid', 'random', 'file'
layoutMode = 'grid';     % <--- Burayı değiştir: 'grid' / 'random' / 'file'

% Depo boyutu (random ve grid icin anlamli)
warehouseWidth  = 40;    % X ekseni maksimum (metre/adim)
warehouseHeight = 30;    % Y ekseni maksimum

% Sipariş toplamada ziyaret edilecek raf sayısı (packing station HARİÇ)
nPickLocations = 10;     % (random modunda kullanılır)

% Grid yerleşim parametreleri (layoutMode = 'grid' için)
nAisles        = 3;      % Koridor sayısı (ör: A,B,C)
racksPerAisle  = 4;      % Her koridorda raf sayısı (ör: 1..4)
aisleSpacing   = 10;     % Koridorlar arası mesafe (X yönü)
rackSpacing    = 8;      % Aynı koridordaki raflar arası mesafe (Y yönü)

% Dosyadan okuma modu (layoutMode = 'file' için)
coordFileName  = 'coords_order1.csv';  % Örn. [x y] kolonları olan bir CSV dosyası

% Packing station (başlangıç/bitiş noktası) koordinatı
packingStation = [0 0];  % (0,0) referans alındı

% Algoritma listesi (istersen buradan algoritma ekle/çıkar)
algList = {'GA','PSO','SA','TS','ACO','ABC'};

% Maksimum iterasyon sayısı (tüm algoritmalar için)
MaxIt = 200;


%% ==== 2. KOORDİNATLARI DİNAMİK OLARAK OLUŞTUR ====

switch lower(layoutMode)
    case 'grid'
        % Profesyonel depo gibi koridor/raf düzeni oluştur
        % X: koridorlar (aisle)
        % Y: raflar (rack)
        
        % Packing station en başta (0,0)
        coords = packingStation;   % 1. nokta
        
        for a = 1:nAisles
            xAisle = a * aisleSpacing;  % koridorun x konumu
            for r = 1:racksPerAisle
                yRack = r * rackSpacing;
                coords = [coords; xAisle, yRack]; %#ok<AGROW>
            end
        end
        
        stopNames = cell(size(coords,1),1);
        stopNames{1} = 'Packing Station';
        idx = 2;
        for a = 1:nAisles
            for r = 1:racksPerAisle
                stopNames{idx} = sprintf('Raf %c%d', 'A'+(a-1), r);
                idx = idx + 1;
            end
        end
        
    case 'random'
        % Belirlenen depo alanı içinde rastgele raflar
        % 1. nokta packing station, geri kalanı rastgele
        
        coords = zeros(nPickLocations+1, 2);
        coords(1,:) = packingStation;
        coords(2:end,1) = warehouseWidth  * rand(nPickLocations,1);
        coords(2:end,2) = warehouseHeight * rand(nPickLocations,1);
        
        stopNames = cell(size(coords,1),1);
        stopNames{1} = 'Packing Station';
        for k = 2:size(coords,1)
            stopNames{k} = sprintf('Raf_%02d', k-1);
        end
        
    case 'file'
        % Koordinatlar dis dosyadan okunur
        % Dosya formatı: her satır [x y]
        % İstersen ilk satır packing station, geri kalanı raflar olacak şekilde düzenleyebilirsin.
        
        coords = readmatrix(coordFileName);  % Örn: coords_order1.csv
        if size(coords,2) ~= 2
            error('Koordinat dosyasi en az 2 kolona sahip olmalidir: [x y]');
        end
        
        % Packing station'i dosyada yok sayip ilk satir olarak eklemek istersen:
        % coords = [packingStation; coords];
        
        % İsimler: varsa dosyadan da okunabilir, şimdilik otomatik üretelim
        nCities = size(coords,1);
        stopNames = cell(nCities,1);
        for k = 1:nCities
            stopNames{k} = sprintf('Nokta_%02d', k);
        end
        
    otherwise
        error('Gecersiz layoutMode. "grid", "random" veya "file" kullanin.');
end

nCities = size(coords,1);

fprintf('Dinamik depo TSP olusturuldu. Nokta sayisi: %d\n', nCities);
fprintf(' 1. nokta: Packing station (baslangic/bitis)\n');


%% ==== 3. MESAFE MATRİSİNİ OLUŞTUR (TSP) ====

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

% TSP problem yapısını doldur
problem.nCities    = nCities;
problem.coords     = coords;
problem.distMatrix = distMatrix;
problem.name       = sprintf('Dinamik Depo TSP (%s)', layoutMode);

%% ==== 4. METASEZGİSELLERİ ÇALIŞTIR ====

nAlgs = numel(algList);

BestTours        = cell(nAlgs,1);
BestCosts        = zeros(nAlgs,1);
BestCostHistory  = cell(nAlgs,1);
RunTimes         = zeros(nAlgs,1);

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

        otherwise
            error('Bilinmeyen algoritma: %s', algo);
    end

    RunTimes(a) = toc;

    fprintf('%s tamamlandi. En iyi maliyet = %.4f, Sure = %.4f sn\n', ...
        algo, BestCosts(a), RunTimes(a));

    % En iyi turu çiz
    figure('Name',['Best Tour - ' algo ' (Dynamic Warehouse)']);
    PlotTSPTour(problem, BestTours{a}, ...
        sprintf('%s - En Iyi Tur - Maliyet: %.2f, Sure: %.2f sn', ...
        algo, BestCosts(a), RunTimes(a)));

    % Nokta isimlerini komut penceresinde göster
    bestTour = BestTours{a};
    fprintf('> %s icin en iyi rota (sira ile):\n', algo);
    for k = 1:length(bestTour)
        idx = bestTour(k);
        if idx <= numel(stopNames)
            fprintf('%2d: %s\n', idx, stopNames{idx});
        else
            fprintf('%2d: Nokta_%02d\n', idx, idx);
        end
    end
    fprintf('\n');
end

%% ==== 5. CONVERGENCE CURVE KARŞILAŞTIRMASI ====

figure('Name','Convergence Curves - Dynamic Warehouse TSP');
colors = lines(nAlgs);
for a = 1:nAlgs
    hist = BestCostHistory{a};
    plot(hist, 'Color', colors(a,:), 'LineWidth', 1.8); hold on;
end
grid on;
xlabel('Iterasyon');
ylabel('En Iyi Maliyet');
title(sprintf('Dinamik Depo TSP - Convergence (%s)', layoutMode));
legend(algList, 'Location','best');

%% ==== 6. ÖZET TABLO ====

resultsTable = table(algList', BestCosts, RunTimes, ...
    'VariableNames', {'Algorithm','BestCost','RunTime'});

disp(' ');
disp('==== Dinamik Depo TSP - Ozet Sonuclar ====');
disp(resultsTable);
