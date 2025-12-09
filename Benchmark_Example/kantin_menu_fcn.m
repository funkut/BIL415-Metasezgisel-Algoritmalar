% kantin_menu_fcn.m
% Okul Kantini Haftalık Menü Planlama problemi için maliyet fonksiyonu
% x: 1x35 vektör (7 gün × 5 ürün)

function z = kantin_menu_fcn(x)

    x = x(:)';   % güvenlik önlemi
    
    nDays = 7;
    nItems = 5;

    % x'i 7x5 matrise dönüştürelim (okuması kolay)
    X = reshape(x, [nItems, nDays])';

    % ----- Talep tahminleri -----
    % 7 gün × 5 ürün (örnek değerler)
    Demand = [
        80 50 60 40 30;
        90 55 70 45 35;
        85 48 65 38 28;
        100 60 75 50 40;
        95 52 70 42 32;
        110 65 80 55 45;
        120 70 90 60 50
    ];

    % ----- İsraf ve eksik satış katsayıları -----
    WasteCost  = [1.0 0.8 0.7 1.2 1.5];  % fazla üretim çarpanı
    ShortCost  = [2.0 1.5 1.2 2.5 3.0];  % eksik üretim çarpanı

    % ----- Maliyet hesabı -----
    z = 0;
    for d = 1:nDays
        for u = 1:nItems
            excess   = max(0, X(d,u) - Demand(d,u));
            shortage = max(0, Demand(d,u) - X(d,u));

            z = z + WasteCost(u)*excess^2 + ShortCost(u)*shortage^2;
        end
    end
end
