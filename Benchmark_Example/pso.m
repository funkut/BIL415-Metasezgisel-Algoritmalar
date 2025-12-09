% pso.m
% Parçacık Sürüsü Optimizasyonu (PSO)

function [BestSol, BestCost, ConvergenceCurve] = pso(problem, params)

    CostFunction = problem.CostFunction;
    nVar   = problem.nVar;
    VarMin = problem.VarMin;
    VarMax = problem.VarMax;

    % Parametreler
    MaxIt = params.MaxIt;
    nPop  = params.nPop;
    
    w     = params.w;
    wdamp = params.wdamp;
    c1    = params.c1;
    c2    = params.c2;

    % Hız sınırları
    VelMax = 0.2*(VarMax-VarMin);
    VelMin = -VelMax;

    % Parçacık şablonu
    empty_particle.Position = [];
    empty_particle.Velocity = [];
    empty_particle.Cost     = [];
    empty_particle.Best.Position = [];
    empty_particle.Best.Cost     = [];

    % Popülasyon dizisi
    particle = repmat(empty_particle, nPop, 1);

    % Global en iyi
    GlobalBest.Cost = inf;

    % Başlangıç popülasyonu
    for i = 1:nPop
        particle(i).Position = VarMin + (VarMax-VarMin)*rand(1, nVar);
        particle(i).Velocity = zeros(1, nVar);
        particle(i).Cost     = CostFunction(particle(i).Position);

        particle(i).Best.Position = particle(i).Position;
        particle(i).Best.Cost     = particle(i).Cost;

        if particle(i).Best.Cost < GlobalBest.Cost
            GlobalBest = particle(i).Best;
        end
    end

    % Yakınsama eğrisi
    ConvergenceCurve = zeros(MaxIt, 1);

    % Ana döngü
    for it = 1:MaxIt
        for i = 1:nPop
            % Hız güncelle
            particle(i).Velocity = w*particle(i).Velocity ...
                + c1*rand(1, nVar).*(particle(i).Best.Position - particle(i).Position) ...
                + c2*rand(1, nVar).*(GlobalBest.Position - particle(i).Position);

            % Hız sınırla
            particle(i).Velocity = max(particle(i).Velocity, VelMin);
            particle(i).Velocity = min(particle(i).Velocity, VelMax);

            % Konum güncelle
            particle(i).Position = particle(i).Position + particle(i).Velocity;

            % Konum sınırla
            particle(i).Position = max(particle(i).Position, VarMin);
            particle(i).Position = min(particle(i).Position, VarMax);

            % Yeni maliyet
            particle(i).Cost = CostFunction(particle(i).Position);

            % Bireysel en iyi güncelle
            if particle(i).Cost < particle(i).Best.Cost
                particle(i).Best.Position = particle(i).Position;
                particle(i).Best.Cost     = particle(i).Cost;

                % Global en iyi güncelle
                if particle(i).Best.Cost < GlobalBest.Cost
                    GlobalBest = particle(i).Best;
                end
            end
        end

        % Yakınsama kaydı
        ConvergenceCurve(it) = GlobalBest.Cost;

        % İterasyon bilgisi
        % fprintf('PSO It=%d BestCost=%.4e\n', it, GlobalBest.Cost);

        % Atalet sönümleme
        w = w * wdamp;
    end

    BestSol  = GlobalBest.Position;
    BestCost = GlobalBest.Cost;
end
