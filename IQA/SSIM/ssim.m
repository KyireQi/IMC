function [mssim, ssim_map] = ssim_index(img1, img2, K, window, L)

    %========================================================================
    %SSIM Index, Version 1.0
    %Copyright(c) 2003 Zhou Wang
    %All Rights Reserved.
    %
    %The author is with Howard Hughes Medical Institute, and Laboratory
    %for Computational Vision at Center for Neural Science and Courant
    %Institute of Mathematical Sciences, New York University.
    %
    %----------------------------------------------------------------------
    %Permission to use, copy, or modify this software and its documentation
    %for educational and research purposes only and without fee is hereby
    %granted, provided that this copyright notice and the original authors'
    %names appear on all copies and supporting documentation. This program
    %shall not be used, rewritten, or adapted as the basis of a commercial
    %software or hardware product without first obtaining permission of the
    %authors. The authors make no representations about the suitability of
    %this software for any purpose. It is provided "as is" without express
    %or implied warranty.
    %----------------------------------------------------------------------
    %
    %This is an implementation of the algorithm for calculating the
    %Structural SIMilarity (SSIM) index between two images. Please refer
    %to the following paper:
    %
    %Z. Wang, A. C. Bovik, H. R. Sheikh, and E. P. Simoncelli, "Image
    %quality assessment: From error measurement to structural similarity"
    %IEEE Transactios on Image Processing, vol. 13, no. 1, Jan. 2004.
    %
    %Kindly report any suggestions or corrections to zhouwang@ieee.org
    %
    %----------------------------------------------------------------------
    %
    %Input : (1) img1: the first image being compared
    %        (2) img2: the second image being compared
    %        (3) K: constants in the SSIM index formula (see the above
    %            reference). defualt value: K = [0.01 0.03]
    %        (4) window: local window for statistics (see the above
    %            reference). default widnow is Gaussian given by
    %            window = fspecial('gaussian', 11, 1.5);
    %        (5) L: dynamic range of the images. default: L = 255
    %
    %Output: (1) mssim: the mean SSIM index value between 2 images.
    %            If one of the images being compared is regarded as 
    %            perfect quality, then mssim can be considered as the
    %            quality measure of the other image.
    %            If img1 = img2, then mssim = 1.
    %        (2) ssim_map: the SSIM index map of the test image. The map
    %            has a smaller size than the input images. The actual size:
    %            size(img1) - size(window) + 1.
    %
    %Default Usage:
    %   Given 2 test images img1 and img2, whose dynamic range is 0-255
    %
    %   [mssim ssim_map] = ssim_index(img1, img2);
    %
    %Advanced Usage:
    %   User defined parameters. For example
    %
    %   K = [0.05 0.05];
    %   window = ones(8);
    %   L = 100;
    %   [mssim ssim_map] = ssim_index(img1, img2, K, window, L);
    %
    %See the results:
    %
    %   mssim                        %Gives the mssim value
    %   imshow(max(0, ssim_map).^4)  %Shows the SSIM index map
    %
    %========================================================================

    % 两种错误情况的处理
    % ----------------------------------------
    % 参数传递错误
    if (nargin < 2 || nargin > 5) 
        ssim_index = -Inf;
        ssim_map = -Inf;
        return;
    end
    % 需要比较的两幅图像的大小不一致
    if (size(img1) ~= size(img2)) 
        ssim_index = -Inf;
        ssim_map = -Inf;
        return;
    end
    % ----------------------------------------
    
    % 得到图像宽高
    % ----------------------------------------
    [M N] = size(img1);
    % ----------------------------------------

    % 下面进行初始化，根据用户提供的不同参数的数量给出了不同的初始化方式
    % ----------------------------------------
    % 如果只给出了两个参数，也就是两幅图片，则采用Gaussian 11x11窗口。
    if (nargin == 2)
        if ((M < 11) || (N < 11)) % 图片的大小小于窗口，错误！
            ssim_index = -Inf;
            ssim_map = -Inf;
            return
        end
        % 进行默认设置初始化
        window = fspecial('gaussian', 11, 1.5);	%
        K(1) = 0.01;								      % default settings
        K(2) = 0.03;								      %
        L = 255;                                  %
    end
    % ----------------------------------------
    % 如果给了三个参数：两幅图像和K的取值的处理：
    if (nargin == 3)
        % 需要学习的地方：每次进行处理必须进行错误判断，以此提高程序的稳定性。
        if ((M < 11) || (N < 11))
            ssim_index = -Inf;
            ssim_map = -Inf;
            return
        end
        window = fspecial('gaussian', 11, 1.5);
        L = 255;
        % 这里也需要错误判断！首先我们有C1和C2两个常数项，所以需要两个K值进行计算，其次，这两个值都需要是非负的。
        if (length(K) == 2)
            if (K(1) < 0 || K(2) < 0)
                ssim_index = -Inf;
                ssim_map = -Inf;
                return;
            end
        else
            ssim_index = -Inf;
            ssim_map = -Inf;
            return;
        end
    end
    % ----------------------------------------
    % 如果参数数量为4，图像，K值和窗函数类型。
    if (nargin == 4) 
        % 获得窗函数参数：
        [H W] = size(window);
        % 这里还是进行一步判断，窗函数的大小不能太小，否则会出现比较严重的blocking，其次窗的大小不能比图像大。
        if ((H * W) < 4 || (H > M) || (W > N))
            ssim_index = -Inf;
            ssim_map = -Inf;
            return
        end
        L = 255;
        if (length(K) == 2)
            if (K(1) < 0 || K(2) < 0)
                ssim_index = -Inf;
                ssim_map = -Inf;
                return;
            end
        else
            ssim_index = -Inf;
            ssim_map = -Inf;
            return;
        end
    end
    % ----------------------------------------
    % 如果五个参数全部给出来了
    if (nargin == 5)
        [H W] = size(window);
        if ((H*W) < 4 || (H > M) || (W > N))
            ssim_index = -Inf;
            ssim_map = -Inf;
            return
        end
        if (length(K) == 2)
            if (K(1) < 0 || K(2) < 0)
                ssim_index = -Inf;
                ssim_map = -Inf;
                return;
            end
        else
            ssim_index = -Inf;
            ssim_map = -Inf;
            return;
        end
    end
    % end ----------------------------------------

    % 进行SSIM的具体运算
    % ----------------------------------------
    C1 = (K(1)*L)^2;  % 亮度式的常数项
    C2 = (K(2)*L)^2;  % 对比度常数项
    window = window / sum(sum(window)); % 归一化
    img1 = double(img1);
    img2 = double(img2);
    
    mu1   = filter2(window, img1, 'valid'); % filter2 是一个数字滤波器，根据window的系数，对img1中的数据采用FIR，valid表示仅计算没有补零边缘的滤波数据。
    mu2   = filter2(window, img2, 'valid'); % 同上
    mu1_sq = mu1.*mu1; % ux^2
    mu2_sq = mu2.*mu2; % uy^2
    mu1_mu2 = mu1.*mu2; % uxuy
    % 下面的公式用到了D(x) = E(x^2) - E(x)^2!!
    sigma1_sq = filter2(window, img1.*img1, 'valid') - mu1_sq;
    sigma2_sq = filter2(window, img2.*img2, 'valid') - mu2_sq;
    sigma12 = filter2(window, img1.*img2, 'valid') - mu1_mu2;
    
    if (C1 > 0 & C2 > 0)
        ssim_map = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))./((mu1_sq + mu2_sq + C1).*(sigma1_sq + sigma2_sq + C2));
    else % 这里为了防止C1/C2 = 0的情况还单独进行了判断
        % 分开计算分子分母
        numerator1 = 2*mu1_mu2 + C1;
        numerator2 = 2*sigma12 + C2;
        denominator1 = mu1_sq + mu2_sq + C1;
        denominator2 = sigma1_sq + sigma2_sq + C2;
        ssim_map = ones(size(mu1));
        index = (denominator1.*denominator2 > 0); % 这里是把分母>0的矩阵下标放进了index
        ssim_map(index) = (numerator1(index).*numerator2(index))./(denominator1(index).*denominator2(index)); % 先计算分母大于0的所有值。
        index = (denominator1 ~= 0) & (denominator2 == 0); % 获得denominator1不为0，denominator2为0的下标
        ssim_map(index) = numerator1(index)./denominator1(index);
        % 由于D(x) = E(x^2) - E(x)^2，所以只能出现mu1_sq + mu2_sq != 0而sigma1_sq + sigma2_sq = 0的情况。
    end
    
    mssim = mean2(ssim_map); % 求取均值
    
    return
    % end ----------------------------------------