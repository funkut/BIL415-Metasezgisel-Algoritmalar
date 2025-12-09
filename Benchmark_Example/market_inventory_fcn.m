% market_inventory_fcn.m
% Süpermarket stok optimizasyonu maliyet fonksiyonu
%
% x: 1 x N boyutlu vektör (her eleman bir ürünün sipariş miktarı)
% çıktı: toplam maliyet (holding + shortage)

function z = market_inventory_fcn(x)

    x = x(:)';              % güvenlik için satır vektör yap

    N = numel(x);           % ürün sayısı (problem.nVar ile uyumlu olmalı)

    % ---- Parametreler (örnek) ----
    % Burada talep, holding ve shortage maliyetlerini tanımlıyoruz.
    % İstersen bunları daha "gerçekçi" yapmak için veriden de okuyabilirsin.
    
    % Ortalama talep (D_i)
    % Örnek: 100 ile 300 arasında değişen talep değerleri
    rng(123);   % tekrar üretilebilirlik için sabit seed (öğrencilerden isteyebilirsin)
    D = 100 + 200*rand(1, N);   % 100-300 arası
    
    % Holding cost (h_i) - stokta fazla tutmanın maliyeti
    h = 0.5 + 1.5*rand(1, N);   % 0.5 - 2.0 arası
    
    % Shortage cost (p_i) - stok yetersizliği maliyeti (genelde daha yüksek)
    p = 2.0 + 3.0*rand(1, N);   % 2.0 - 5.0 arası

    % ---- Maliyet Hesabı ----
    shortage = max(0, D - x);   % talebin altında kalan kısım
    holding  = max(0, x - D);   % talebin üstünde kalan kısım

    cost_short = p .* (shortage.^2);
    cost_hold  = h .* (holding.^2);

    % Toplam maliyet
    z = sum(cost_short + cost_hold);
end
