function PlotTSPTour(problem, tour, titleStr)
% PlotTSPTour
% Verilen turu 2B düzlemde çizer.
%
% problem: CreateTSPInstance çıktısı
% tour: 1 x nCities permütasyon vektörü
% titleStr: figure başlığı (string)

    coords = problem.coords;
    tour   = tour(:)';

    n = problem.nCities;

    % Kapanmamışsa başlangıca geri ekle
    if tour(1) ~= tour(end)
        tour = [tour tour(1)];
    end

    % X ve Y koordinatlarını sırayla al
    x = coords(tour, 1);
    y = coords(tour, 2);

    plot(x, y, '-o', 'LineWidth', 1.5, 'MarkerSize', 6);
    grid on;
    xlabel('X');
    ylabel('Y');
    axis equal;

    % Şehir numaralarını yanına yaz
    hold on;
    for i = 1:n
        text(coords(i,1) + 1, coords(i,2) + 1, num2str(i), 'FontSize', 8);
    end
    hold off;

    if nargin >= 3 && ~isempty(titleStr)
        title(titleStr, 'Interpreter', 'none');
    else
        title('TSP Turu');
    end

end
