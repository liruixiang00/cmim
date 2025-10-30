function cp_showMatch(I1, I2, loc1, loc2, E, saveName)
    % 提取内点和外点索引
    figure; % 新建窗口防止覆盖

    inliersIndex = E < 3;   % 内点
    outliersIndex = E >= 3; % 外点

    inliers1 = loc1(inliersIndex, :);
    inliers2 = loc2(inliersIndex, :);
    outliers1 = loc1(outliersIndex, :);
    outliers2 = loc2(outliersIndex, :);

    % 若图像为灰度，转换为三通道
    if size(I1, 3) == 1
        I1 = repmat(I1, [1, 1, 3]);
    end
    if size(I2, 3) == 1
        I2 = repmat(I2, [1, 1, 3]);
    end

    % 拼接图像
    [h1, w1] = size(I1, [1, 2]);
    [h2, w2] = size(I2, [1, 2]);
    if h1 < h2
        I1 = padarray(I1, [h2 - h1, 0], 0, 'post');
    elseif h1 > h2
        I2 = padarray(I2, [h1 - h2, 0], 0, 'post');
    end
    compositeImg = [I1, I2];

    % 显示匹配点
    imshow(compositeImg, 'Border', 'tight');
    hold on;
    plot(loc1(:,1), loc1(:,2), 'ro', 'MarkerSize', 5,'LineWidth',1);
    plot(loc2(:,1) + w1, loc2(:,2), 'g+', 'MarkerSize', 5,'LineWidth',1);

    for i = 1:size(outliers1,1)
        line([outliers1(i,1) outliers2(i,1)+w1], [outliers1(i,2) outliers2(i,2)], ...
             'Color', 'r', 'LineWidth', 1);
    end
    
    for i = 1:size(inliers1,1)
        line([inliers1(i,1) inliers2(i,1)+w1], [inliers1(i,2) inliers2(i,2)], ...
             'Color', 'y', 'LineWidth', 1);
    end

    hold off;
    set(gca, 'LooseInset', get(gca, 'TightInset'));

    % === 使用传入的 saveName 保存 ===
    if nargin < 6 || isempty(saveName)
        saveName = 'match_result.png'; % 默认文件名
    end

    % === 600 dpi 保存 ===
    print(gcf, saveName, '-dpng', '-r600');
    fprintf(' 匹配结果已保存为: %s (600 dpi)\n', saveName);
end
