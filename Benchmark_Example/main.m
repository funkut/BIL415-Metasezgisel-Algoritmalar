% main.m
% Tüm benchmark fonksiyonlarını birden çok metasezgisel algoritma ile
% çalıştıran modüler ana dosya.
%
% Kullanılan algoritmalar:
%   - PSO        -> pso.m
%   - GWO        -> gwo.m
%   - DE         -> de.m
%   - GA (simple)-> ga_simple.m
%   - SA (simple)-> sa_simple.m
%
% Benchmark fonksiyonları:
%   get_benchmark_functions.m içinden geliyor.
%
% NOT: Algoritma fonksiyonlarının imzası aynı:
%   [BestSol, BestCost, Conv] = algoFunc(problem, params)

clear; clc; close all;

%% ========== Benchmark Problemlerini Yükle ==========
problems = get_benchmark_functions();
nProblems = numel(problems);

%% ========== Algoritma Listesi ==========
% Buraya yeni algoritma eklemek yeterli:
algorithms = { @pso,        ... % 1
               @gwo,        ... % 2
               @de,         ... % 3
               @ga_simple,  ... % 4
               @sa_simple   ... % 5
             };

algoNames  = { 'PSO', ...
               'GWO', ...
               'DE', ...
               'GA', ...
               'SA' };

nAlgos = numel(algorithms);

%% ========== Genel Parametreler (Tüm Algoritmalara Giden) ==========

% Ortak parametreler (MaxIt, nPop)
params.MaxIt = 20000;   % Maksimum iterasyon
params.nPop  = 30;    % Popülasyon boyutu (kullanan algoritmalar için)

% PSO'ya özel parametreler
params.w     = 0.1;   % Inertia weight
params.wdamp = 0.99;  % Inertia sönümleme
params.c1    = 0.5;   % Bilişsel katsayı
params.c2    = 2.5;   % Sosyal katsayı

% DE'ye özel (de.m içinde default da var, istersen buradan override edebilirsin)
params.F     = 0.8;   % Diferansiyel ağırlık
params.CR    = 0.9;   % Crossover oranı

% GA'ya özel (ga_simple.m içinde default da var)
params.pc    = 0.7;   % Crossover oranı
params.pm    = 0.1;   % Mutation oranı
params.mu    = 0.1;   % Mutation step (sigma)
params.beta  = 1;     % Selection pressure

% SA'ya özel (sa_simple.m içinde default da var)
params.T0    = 1.0;   % Başlangıç sıcaklığı
params.alpha = 0.95;  % Soğutma oranı
params.nMove = 20;    % Her sıcaklıkta deneme sayısı
params.sigma = 0.1;   % Perturbation ölçeği

%% ========== Sonuçları Tutmak İçin ==========
Results = struct;

%% ========== Ana Döngü: Her Problem x Her Algoritma ==========
for p = 1:nProblems
    prob = problems(p);
    
    fprintf('\n=========================================\n');
    fprintf('Problem %d / %d: %s\n', p, nProblems, prob.Name);
    fprintf('Boyut: %d  |  Aralık: [%.2f , %.2f]\n', ...
        prob.nVar, prob.VarMin, prob.VarMax);
    fprintf('=========================================\n');
    
    for a = 1:nAlgos
        algoFunc = algorithms{a};
        algoName = algoNames{a};
        
        fprintf('> Algoritma: %-6s calisiyor... ', algoName);
        
        % Algoritmayı çalıştır
        tic;
        [bestSol, bestCost, convCurve] = algoFunc(prob, params);
        % bestSol -> en iyi (besti) durumu konum (1 x dim)
        % bestCost -> en iyi değer (optimum)
        % convCurve -> 1'den MaxIt'e kadar çalışırken buldugunuz degerler
        elapsedTime = toc;
        
        % Sonuçları kaydet
        Results(p,a).AlgoName  = algoName;
        Results(p,a).Problem   = prob.Name;
        Results(p,a).BestSol   = bestSol;
        Results(p,a).BestCost  = bestCost;
        Results(p,a).ConvCurve = convCurve;
        Results(p,a).Time      = elapsedTime;
        
        fprintf('En iyi uygunluk = %.4e  |  Sure = %.3f s\n', bestCost, elapsedTime);
    end
end

%% ========== Örnek Yakınsama Grafiği (1. Problem İçin) ==========

figure;
hold on; grid on;
title(sprintf('Yakinsama Egrileri - Problem: %s', problems(1).Name), 'Interpreter', 'none');
xlabel('Iterasyon');
ylabel('En Iyi Uygunluk (Cost)');

for a = 1:nAlgos
    convCurve = Results(1,a).ConvCurve;
    plot(convCurve, 'DisplayName', Results(1,a).AlgoName);
end
legend('show', 'Location', 'best');
set(gca,'YScale','log');   % log-scale görmek güzel olur (istersen kaldır)
hold off;

%% ========== Konsol Özeti (Tablo Gibi) ==========
fprintf('\n\n===== OZET TABLO (Son Iterasyondaki En Iyi Cost) =====\n');
for p = 1:nProblems
    fprintf('\nProblem: %s\n', problems(p).Name);
    for a = 1:nAlgos
        fprintf('  %-6s : BestCost = %.4e  |  Time = %.3f s\n', ...
                Results(p,a).AlgoName, Results(p,a).BestCost, Results(p,a).Time);
    end
end
fprintf('=====================================================\n');
