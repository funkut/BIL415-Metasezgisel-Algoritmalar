function L = TSPCost(tour, problem)
% TSPCost
% Verilen turun (permütasyonun) toplam yol uzunluğunu hesaplar.
% Ek olarak, problem.priority alanı tanımlıysa
%   "öncelik kuralı" ihlalleri icin ceza ekler.
%
% tour    : 1 x nCities veya nCities x 1 permütasyon vektörü
% problem : CreateTSPInstance ile oluşturulan (veya elde yazılan) struct
%
%   problem.priority (opsiyonel):
%       - 1: en yüksek öncelik
%       - 2: orta
%       - 3: düşük (vb.)
%   problem.priorityPenalty (opsiyonel):
%       - ceza katsayısı (varsayılan: 1000)

    % Tour'u satır vektörüne çevir
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

    % --- 1) Normal TSP mesafesi ---
    baseDist = 0;
    for k = 1:length(tour)-1
        i = tour(k);
        j = tour(k+1);
        baseDist = baseDist + D(i,j);
    end

    L = baseDist;   % simdilik sadece mesafe

    % --- 2) Öncelik cezası (varsa) ---
    if isfield(problem, 'priority') && ~isempty(problem.priority)

        % Öncelik vektörü, 1: en yüksek, 2: orta, 3: düşük ...
        pr = problem.priority(:)';  % satır vektör

        % Ceza katsayısı (yoksa default)
        if isfield(problem, 'priorityPenalty') && ~isempty(problem.priorityPenalty)
            lambda = problem.priorityPenalty;
        else
            lambda = 1000;   % default ceza büyüklüğü (mesafeden çok daha büyük olmalı)
        end

        % Ziyaret sırası (sondaki tekrar baslangici atabiliriz)
        visitSeq = tour(1:end-1);

        penalty = 0;

        % Basit kural:
        %  i<j ama pr(visitSeq(i)) > pr(visitSeq(j)) ise:
        %     Daha düşük öncelikli bir yere daha önce gitmiş, sonra
        %     daha yüksek öncelikli gelmiş -> ihlal.
        %
        % 1 = en yüksek öncelik, yani "daha küçük sayı = daha önemli".
        %
        % Örneğin:
        %   priority: [1 1 2 3]
        %   sırada: (4 -> 2)   (önce 3, sonra 1) -> ceza
        for i = 1:numel(visitSeq)-1
            for j = i+1:numel(visitSeq)
                pi = pr(visitSeq(i));
                pj = pr(visitSeq(j));
                if pi > pj
                    % Öncelik farkı kadar ceza ekleyelim
                    penalty = penalty + (pi - pj);
                end
            end
        end

        % Toplam maliyete ceza ekle
        L = L + lambda * penalty;
    end
end
