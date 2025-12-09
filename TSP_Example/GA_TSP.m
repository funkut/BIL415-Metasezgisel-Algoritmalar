function [BestTour, BestCost, BestCostHistory] = GA_TSP(problem, params)
% GA_TSP
% Gezgin Satici Problemi (TSP) icin Genetik Algoritma
%
% Girdi:
%   problem : CreateTSPInstance ile olusan yapi
%   params  : GA parametreleri (MaxIt, nPop, Pc, Pm, TourSize)
%
% Cikti:
%   BestTour        : En iyi bulunan tur (1..nCities permutasyonu)
%   BestCost        : Bu turun maliyeti
%   BestCostHistory : Her iterasyondaki en iyi maliyet (convergence curve)

    %% Problem boyutu
    nCities = problem.nCities;

    %% Varsayilan parametreler (params icinde yoksa)
    if ~isfield(params, 'MaxIt'),     params.MaxIt = 200; end   % Maks. iterasyon
    if ~isfield(params, 'nPop'),      params.nPop  = 40;  end   % Populasyon sayisi
    if ~isfield(params, 'Pc'),        params.Pc    = 0.8; end   % Crossover orani
    if ~isfield(params, 'Pm'),        params.Pm    = 0.2; end   % Mutasyon orani
    if ~isfield(params, 'TourSize'),  params.TourSize = 3; end  % Turnuva boyutu

    MaxIt    = params.MaxIt;
    nPop     = params.nPop;
    Pc       = params.Pc;
    Pm       = params.Pm;
    TourSize = params.TourSize;

    % Uretilecek cocuk (crossover birey) sayisi
    nC = 2 * round((Pc * nPop) / 2);   % Cift sayi olsun diye 2*round(...)

    % Mutasyona ugrayacak birey sayisi
    nM = round(Pm * nPop);

    %% Birey yapisi
    empty_individual.Position = [];   % Tur (perm.)
    empty_individual.Cost     = [];   % Maliyet

    %% Baslangic populasyonu
    pop = repmat(empty_individual, nPop, 1);

    for i = 1:nPop
        % Her bireyin turu: 1..nCities permutasyonu
        pop(i).Position = randperm(nCities);
        % TSPCost ile maliyeti hesapla
        pop(i).Cost     = TSPCost(pop(i).Position, problem);
    end

    % Baslangic en iyi birey
    [~, bestIdx] = min([pop.Cost]);
    BestSol = pop(bestIdx);

    % Her iterasyondaki en iyi maliyeti kaydedecek vektor
    BestCostHistory = nan(MaxIt, 1);

    %% Ana GA dongusu
    for it = 1:MaxIt

        % === Crossover ile cocuk uretimi ===
        popc = repmat(empty_individual, nC, 1);

        for k = 1:2:nC   % ikiser ikiser cocuk uret (k ve k+1)
            % Turnuva secimi ile 2 ebeveyn sec
            i1 = TournamentSelection([pop.Cost], TourSize);
            i2 = TournamentSelection([pop.Cost], TourSize);

            p1 = pop(i1).Position;
            p2 = pop(i2).Position;

            % OX (Order Crossover) uygula
            [c1, c2] = OX_Crossover(p1, p2);

            popc(k).Position   = c1;
            popc(k+1).Position = c2;
        end

        % === Mutasyon bireyleri ===
        popm = repmat(empty_individual, nM, 1);

        for k = 1:nM
            % Rastgele bir birey sec
            i = randi(nPop);
            p = pop(i).Position;

            % Swap mutation (iki sehri yer degistir)
            p_new = SwapMutation(p);

            popm(k).Position = p_new;
        end

        % === Yeni bireylerin maliyetini hesapla ===
        newpop = [popc; popm];   % cocuklar + mutasyon bireyleri
        for i = 1:numel(newpop)
            newpop(i).Cost = TSPCost(newpop(i).Position, problem);
        end

        % === Eski populasyon ile birlestir ===
        pop = [pop; newpop];     %#ok<AGROW>

        % === Tum bireyleri maliyete gore sirala ve en iyi nPop'u tut ===
        [~, sortIdx] = sort([pop.Cost]);   % kucuk maliyet basa
        pop = pop(sortIdx);
        pop = pop(1:nPop);                 % en iyi nPop bireyi koru

        % === Global en iyi cozum guncelle ===
        if pop(1).Cost < BestSol.Cost
            BestSol = pop(1);
        end

        % Bu iterasyondaki en iyi maliyeti kaydet
        BestCostHistory(it) = BestSol.Cost;

        fprintf('GA  It %3d: En Iyi Maliyet = %.4f\n', it, BestCostHistory(it));
    end

    % Ciktiya aktar
    BestTour = BestSol.Position;
    BestCost = BestSol.Cost;

end

%% ================= Yardimci Fonksiyonlar =================

function i = TournamentSelection(costs, TourSize)
% TournamentSelection
% Basit turnuva secimi:
%   1) Rastgele TourSize kadar aday sec
%   2) Maliyeti en dusuk olan kazanir

    n = numel(costs);
    candidates = randi(n, [1, TourSize]);      % rastgele indeksler
    [~, idx]   = min(costs(candidates));       % iclerinde en kucuk maliyet
    i          = candidates(idx);              % kazananin global indeksi

end

function [c1, c2] = OX_Crossover(p1, p2)
% OX_Crossover
% Order Crossover (OX) - TSP icin uygun
%   p1, p2 : ebeveynler
%   c1, c2 : cocuklar

    n = numel(p1);

    c1 = zeros(1, n);
    c2 = zeros(1, n);

    % Rastgele iki kesim noktasi sec
    i1 = randi([1, n-1]);
    i2 = randi([i1+1, n]);

    % Ebeveynlerden segment kopyala
    c1(i1:i2) = p1(i1:i2);
    c2(i1:i2) = p2(i1:i2);

    % Eksik kalan sehirleri diger ebeveynin sirasiyle doldur
    c1 = FillRemaining(c1, p2, i1, i2);
    c2 = FillRemaining(c2, p1, i1, i2);

end

function child = FillRemaining(child, parent, i1, i2)
% FillRemaining
% OX icin, child icinde 0 olan yerlere, parent'in sehirlerini
% tekrar etmeyecek sekilde, sirayla yerlestirir.

    n = numel(parent);
    currentIndex = mod(i2, n) + 1;  % doldurmaya baslanacak index

    for k = 1:n
        idx = mod(i2 + k - 1, n) + 1;
        city = parent(idx);

        if ~ismember(city, child)
            child(currentIndex) = city;
            currentIndex = mod(currentIndex, n) + 1;
        end
    end

end

function p_new = SwapMutation(p)
% SwapMutation
% TSP turu icin basit mutasyon: iki sehri yer degistirir.

    n = numel(p);
    i = randi(n);
    j = randi(n);
    while j == i
        j = randi(n);
    end

    p_new = p;
    p_new([i j]) = p_new([j i]);

end
