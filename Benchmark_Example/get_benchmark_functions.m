% get_benchmark_functions.m
% Tüm benchmark problemlerini tek bir yerde tanımlayan script

function problems = get_benchmark_functions()

    defaultDim = 30;  % İstersen buradan değiştir

    % --------- F1: Sphere ---------
    problems(1).Name         = 'Sphere';
    problems(1).CostFunction = @sphere_fcn;
    problems(1).nVar         = defaultDim;
    problems(1).VarMin       = -100;
    problems(1).VarMax       =  100;

    % --------- F2: Rastrigin ---------
    problems(2).Name         = 'Rastrigin';
    problems(2).CostFunction = @rastrigin_fcn;
    problems(2).nVar         = defaultDim;
    problems(2).VarMin       = -5.12;
    problems(2).VarMax       =  5.12;

    % --------- F3: Rosenbrock ---------
    problems(3).Name         = 'Rosenbrock';
    problems(3).CostFunction = @rosenbrock_fcn;
    problems(3).nVar         = defaultDim;
    problems(3).VarMin       = -5;
    problems(3).VarMax       =  10;

    % --------- F4: Ackley ---------
    problems(4).Name         = 'Ackley';
    problems(4).CostFunction = @ackley_fcn;
    problems(4).nVar         = defaultDim;
    problems(4).VarMin       = -32.768;
    problems(4).VarMax       =  32.768;

    % --------- F5: Griewank ---------
    problems(5).Name         = 'Griewank';
    problems(5).CostFunction = @griewank_fcn;
    problems(5).nVar         = defaultDim;
    problems(5).VarMin       = -600;
    problems(5).VarMax       =  600;

    % --------- F6: Schwefel ---------
    problems(6).Name         = 'Schwefel';
    problems(6).CostFunction = @schwefel_fcn;
    problems(6).nVar         = defaultDim;
    problems(6).VarMin       = -500;
    problems(6).VarMax       =  500;

    % --------- F7: Zakharov ---------
    problems(7).Name         = 'Zakharov';
    problems(7).CostFunction = @zakharov_fcn;
    problems(7).nVar         = defaultDim;
    problems(7).VarMin       = -10;
    problems(7).VarMax       =  10;
    
        % --------- F8: Market Inventory Optimization ---------
    nProducts = 50;   % problem boyutu (N)
    
    problems(8).Name         = 'MarketInventory';
    problems(8).CostFunction = @market_inventory_fcn;
    problems(8).nVar         = nProducts;
    problems(8).VarMin       = 0;      % her ürün için minimum sipariş
    problems(8).VarMax       = 500;    % her ürün için maksimum sipariş

% --------- F9: KantinMenuOpt ---------

    problems(9).Name         = 'KantinMenuOpt';
    problems(9).CostFunction = @kantin_menu_fcn;
    problems(9).nVar         = 35;      % 7 gün × 5 ürün
    problems(9).VarMin       = 0;
    problems(9).VarMax       = 200;
end

%% ================== COST FONKSIYONLARI ==================

function z = sphere_fcn(x)
    % Sphere fonksiyonu
    z = sum(x.^2);
end

function z = rastrigin_fcn(x)
    % Rastrigin fonksiyonu
    d = numel(x);
    z = 10*d + sum(x.^2 - 10*cos(2*pi*x));
end

function z = rosenbrock_fcn(x)
    % Rosenbrock fonksiyonu
    z = sum(100*(x(2:end)-x(1:end-1).^2).^2 + (x(1:end-1)-1).^2);
end

function z = ackley_fcn(x)
    % Ackley fonksiyonu
    d = numel(x);
    a = 20;
    b = 0.2;
    c = 2*pi;
    
    term1 = -a * exp(-b*sqrt(sum(x.^2)/d));
    term2 = -exp(sum(cos(c*x))/d);
    
    z = term1 + term2 + a + exp(1);
end

% griewank_fcn.m
% Griewank fonksiyonu
% Global minimum: f(0,...,0) = 0

function z = griewank_fcn(x)
    d = numel(x);
    sumTerm = sum(x.^2) / 4000;
    
    prodTerm = 1;
    for i = 1:d
        prodTerm = prodTerm * cos(x(i) / sqrt(i));
    end
    
    z = sumTerm - prodTerm + 1;
end

% schwefel_fcn.m
% Schwefel fonksiyonu
% Global minimum: f(420.9687,...,420.9687) ≈ 0

function z = schwefel_fcn(x)
    d = numel(x);
    z = 418.9829*d - sum(x .* sin(sqrt(abs(x))));
end

% zakharov_fcn.m
% Zakharov fonksiyonu
% Global minimum: f(0,...,0) = 0
function z = zakharov_fcn(x)
    d = numel(x);
    i = 1:d;
    sum1 = sum(x.^2);
    sum2 = sum(0.5 * i .* x);

    z = sum1 + sum2.^2 + sum2.^4;
end


