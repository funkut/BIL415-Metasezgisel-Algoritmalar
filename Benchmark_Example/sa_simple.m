% sa_simple.m
% Basit Simulated Annealing (SA) - Gerçek kodlama

function [BestSol, BestCost, ConvergenceCurve] = sa_simple(problem, params)

    CostFunction = problem.CostFunction;
    nVar   = problem.nVar;
    VarMin = problem.VarMin;
    VarMax = problem.VarMax;

    % Parametreler (yoksa default ata)
    if ~isfield(params, 'MaxIt'),  params.MaxIt  = 200;  end
    if ~isfield(params, 'T0'),     params.T0     = 1.0;  end
    if ~isfield(params, 'alpha'),  params.alpha  = 0.95; end
    if ~isfield(params, 'nMove'),  params.nMove  = 20;   end
    if ~isfield(params, 'sigma'),  params.sigma  = 0.1;  end

    MaxIt = params.MaxIt;   % iterasyon sayısı (soğutma adımı)
    T0    = params.T0;      % başlangıç sıcaklığı
    alpha = params.alpha;   % soğutma oranı
    nMove = params.nMove;   % her T için denenecek çözüm sayısı
    sigma = params.sigma;   % perturbation ölçeği

    % Başlangıç çözümü
    x.Position = VarMin + (VarMax-VarMin).*rand(1,nVar);
    x.Cost     = CostFunction(x.Position);

    % En iyi çözüm
    BestSol  = x.Position;
    BestCost = x.Cost;

    T = T0;   % sıcaklık başlangıcı

    ConvergenceCurve = zeros(MaxIt,1);

    for it = 1:MaxIt
        for k = 1:nMove
            % Komşu çözüm üret (Gaussian perturbation)
            new.Position = x.Position + sigma*randn(1,nVar).*(VarMax-VarMin);
            new.Position = max(new.Position, VarMin);
            new.Position = min(new.Position, VarMax);

            new.Cost = CostFunction(new.Position);

            if new.Cost <= x.Cost
                % Daha iyi ise kabul et
                x = new;
            else
                % Kötü ise olasılıkla kabul et
                delta = new.Cost - x.Cost;
                p = exp(-delta/T);
                if rand <= p
                    x = new;
                end
            end

            % En iyi güncelle
            if x.Cost <= BestCost
                BestCost = x.Cost;
                BestSol  = x.Position;
            end
        end

        ConvergenceCurve(it) = BestCost;

        % Sıcaklığı soğut
        T = alpha*T;

        % fprintf('SA It=%d BestCost=%.4e T=%.4f\n', it, BestCost, T);
    end
end
