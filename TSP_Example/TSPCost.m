function L = TSPCost(tour, problem)
% TSPCost
% Verilen turun (permütasyonun) toplam yol uzunluğunu hesaplar.
%
% tour: 1 x nCities veya nCities x 1 permütasyon vektörü
% problem: CreateTSPInstance ile oluşturulan struct

    % Satır vektörüne çevir
    tour = tour(:)';

    n = problem.nCities;

    if numel(tour) ~= n
        error('TSPCost: Tour boyutu problemdeki sehir sayisi ile uyumsuz!');
    end

    % Permütasyon kontrolü (isteğe bağlı, güvenlik amaçlı)
    if any(sort(tour) ~= 1:n)
        error('TSPCost: Tour 1..n sehirlerinin bir permutasyonu degil!');
    end

    % Turun kapanmış olduğundan emin ol (başlangıç şehrine dön)
    if tour(1) ~= tour(end)
        tour = [tour tour(1)];
    end

    % Toplam mesafe hesapla
    L = 0;
    for k = 1:length(tour)-1
        i = tour(k);
        j = tour(k+1);
        L = L + problem.distMatrix(i,j);
    end

end
