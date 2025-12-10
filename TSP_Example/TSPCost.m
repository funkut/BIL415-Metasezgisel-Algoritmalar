function L = TSPCost(tour, problem)
% TSPCost
% Verilen turun (permütasyonun) toplam yol uzunluğunu hesaplar.
%
% tour    : 1 x nCities veya nCities x 1 permütasyon vektörü
% problem : CreateTSPInstance ile oluşturulan struct

    % Tour'u satır vektörüne çevir (gelen sütun da olabilir)
    tour = tour(:)';

    n = problem.nCities;

    % Tour uzunluğu ile problemdeki şehir sayısı uyuşmalı
    if numel(tour) ~= n
        error('TSPCost: Tour boyutu problemdeki sehir sayisi ile uyumsuz!');
    end

    % Permütasyon kontrolü (isteğe bağlı ama güvenlik için iyi)
    if any(sort(tour) ~= 1:n)
        error('TSPCost: Tour 1..n sehirlerinin bir permutasyonu degil!');
    end

    % Turun başlangıca dönmesini sağla (1..n..1)
    if tour(1) ~= tour(end)
        tour = [tour tour(1)];
    end

    % Mesafe matrisini al
    D = problem.distMatrix;

    % Toplam mesafeyi hesapla
    L = 0;
    for k = 1:length(tour)-1
        i = tour(k);
        j = tour(k+1);
        L = L + D(i,j);
    end
end
