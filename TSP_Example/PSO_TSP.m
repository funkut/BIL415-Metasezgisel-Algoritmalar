function [BestTour, BestCost, BestCostHistory] = PSO_TSP(problem, params)
% PSO_TSP
% TSP icin Parcacik Suru Optimizasyonu (PSO) - random-key temsil ile
%
% Cozum temsili:
%   - Her parcacik bir real vektor: position (1 x nCities)
%   - Bu vektor siralanarak TSP turuna donusturulur (DecodeRealToTour)
%
% Girdi:
%   problem : TSP yapisi
%   params  : MaxIt, nPop, w, c1, c2
%
% Cikti:
%   BestTour        : En iyi bulunan tur (perm.)
%   BestCost        : En iyi turun maliyeti
%   BestCostHistory : Convergence curve

    nCities = problem.nCities;

    % Varsayilan parametreler
    if ~isfield(params,'MaxIt'), params.MaxIt = 200; end
    if ~isfield(params,'nPop'),  params.nPop  = 40;  end
    if ~isfield(params,'w'),    params.w     = 0.7; end
    if ~isfield(params,'c1'),   params.c1    = 1.5; end
    if ~isfield(params,'c2'),   params.c2    = 1.5; end

    MaxIt = params.MaxIt;
    nPop  = params.nPop;
    w     = params.w;
    c1    = params.c1;
    c2    = params.c2;

    % Parcacik yapisi
    empty_particle.Position = [];
    empty_particle.Velocity = [];
    empty_particle.Tour     = [];
    empty_particle.Cost     = inf;
    empty_particle.Best     = struct('Position',[],'Tour',[],'Cost',inf);

    % Populasyonu olustur
    particle = repmat(empty_particle, nPop, 1);
    GlobalBest.Cost = inf;

    for i = 1:nPop
        % Baslangic pozisyonu: [0,1] araliginda rasgele degerler
        particle(i).Position = rand(1, nCities);
        particle(i).Velocity = zeros(1, nCities);

        % Pozisyonu tura cevir
        particle(i).Tour = DecodeRealToTour(particle(i).Position);

        % Maliyet hesapla
        particle(i).Cost = TSPCost(particle(i).Tour, problem);

        % Bireysel en iyi
        particle(i).Best.Position = particle(i).Position;
        particle(i).Best.Tour     = particle(i).Tour;
        particle(i).Best.Cost     = particle(i).Cost;

        % Global en iyi
        if particle(i).Best.Cost < GlobalBest.Cost
            GlobalBest = particle(i).Best;
        end
    end

    BestCostHistory = nan(MaxIt,1);

    % Ana PSO dongusu
    for it = 1:MaxIt

        for i = 1:nPop
            % Hizi guncelle (PSO denklemi)
            r1 = rand(1, nCities);
            r2 = rand(1, nCities);
            particle(i).Velocity = w .* particle(i).Velocity ...
                + c1 .* r1 .* (particle(i).Best.Position - particle(i).Position) ...
                + c2 .* r2 .* (GlobalBest.Position - particle(i).Position);

            % Pozisyonu guncelle
            particle(i).Position = particle(i).Position + particle(i).Velocity;

            % Pozisyonu 0-1 araligina sinirla
            particle(i).Position = max(particle(i).Position, 0);
            particle(i).Position = min(particle(i).Position, 1);

            % Yeni pozisyondan tur elde et
            particle(i).Tour = DecodeRealToTour(particle(i).Position);

            % Yeni maliyeti hesapla
            particle(i).Cost = TSPCost(particle(i).Tour, problem);

            % Bireysel en iyi guncelle
            if particle(i).Cost < particle(i).Best.Cost
                particle(i).Best.Position = particle(i).Position;
                particle(i).Best.Tour     = particle(i).Tour;
                particle(i).Best.Cost     = particle(i).Cost;

                % Global en iyi guncelle
                if particle(i).Best.Cost < GlobalBest.Cost
                    GlobalBest = particle(i).Best;
                end
            end
        end

        BestCostHistory(it) = GlobalBest.Cost;
        fprintf('PSO It %3d: En Iyi Maliyet = %.4f\n', it, BestCostHistory(it));
    end

    BestTour = GlobalBest.Tour;
    BestCost = GlobalBest.Cost;
end

%% --- Yardimci: real vektor -> permutasyon ---
function tour = DecodeRealToTour(position)
    % position vektorunu siralayip indeksleri al
    [~, idx] = sort(position);
    tour = idx;
end
