function problem = CreateTSPInstance(nCities, seed)
% CreateTSPInstance
% Amaç: TSP için şehir koordinatları ve mesafe matrisi oluşturmak
%
% Kullanım:
%   problem = CreateTSPInstance();           % varsayılan 20 şehir
%   problem = CreateTSPInstance(30);         % 30 şehir
%   problem = CreateTSPInstance(30, 1);      % 30 şehir, sabit tohum
%
% Çıktı (problem struct):
%   problem.nCities     -> şehir sayısı
%   problem.coords      -> [x y] koordinatları (n x 2)
%   problem.distMatrix  -> mesafe matrisi (n x n)
%   problem.name        -> problem adı (string)

    if nargin < 1 || isempty(nCities)
        nCities = 20;
    end

    if nargin >= 2 && ~isempty(seed)
        rng(seed);      % Tekrarlanabilirlik
    else
        rng('shuffle'); % Her çalıştırmada farklı
    end

    % Şehir koordinatlarını [0,100] aralığında rasgele üret
    coords = 100 * rand(nCities, 2);

    % Öklid mesafe matrisini hesapla
    distMatrix = zeros(nCities, nCities);
    for i = 1:nCities
        for j = 1:nCities
            if i == j
                distMatrix(i,j) = 0;
            else
                dx = coords(i,1) - coords(j,1);
                dy = coords(i,2) - coords(j,2);
                distMatrix(i,j) = sqrt(dx^2 + dy^2);
            end
        end
    end

    % Problem struct'ını doldur
    problem.nCities    = nCities;
    problem.coords     = coords;
    problem.distMatrix = distMatrix;
    problem.name       = sprintf('Rastgele TSP (%d sehir)', nCities);
end
