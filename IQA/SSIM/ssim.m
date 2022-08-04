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

    % ���ִ�������Ĵ���
    % ----------------------------------------
    % �������ݴ���
    if (nargin < 2 || nargin > 5) 
        ssim_index = -Inf;
        ssim_map = -Inf;
        return;
    end
    % ��Ҫ�Ƚϵ�����ͼ��Ĵ�С��һ��
    if (size(img1) ~= size(img2)) 
        ssim_index = -Inf;
        ssim_map = -Inf;
        return;
    end
    % ----------------------------------------
    
    % �õ�ͼ����
    % ----------------------------------------
    [M N] = size(img1);
    % ----------------------------------------

    % ������г�ʼ���������û��ṩ�Ĳ�ͬ���������������˲�ͬ�ĳ�ʼ����ʽ
    % ----------------------------------------
    % ���ֻ����������������Ҳ��������ͼƬ�������Gaussian 11x11���ڡ�
    if (nargin == 2)
        if ((M < 11) || (N < 11)) % ͼƬ�Ĵ�СС�ڴ��ڣ�����
            ssim_index = -Inf;
            ssim_map = -Inf;
            return
        end
        % ����Ĭ�����ó�ʼ��
        window = fspecial('gaussian', 11, 1.5);	%
        K(1) = 0.01;								      % default settings
        K(2) = 0.03;								      %
        L = 255;                                  %
    end
    % ----------------------------------------
    % ���������������������ͼ���K��ȡֵ�Ĵ���
    if (nargin == 3)
        % ��Ҫѧϰ�ĵط���ÿ�ν��д��������д����жϣ��Դ���߳�����ȶ��ԡ�
        if ((M < 11) || (N < 11))
            ssim_index = -Inf;
            ssim_map = -Inf;
            return
        end
        window = fspecial('gaussian', 11, 1.5);
        L = 255;
        % ����Ҳ��Ҫ�����жϣ�����������C1��C2���������������Ҫ����Kֵ���м��㣬��Σ�������ֵ����Ҫ�ǷǸ��ġ�
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
    % �����������Ϊ4��ͼ��Kֵ�ʹ��������͡�
    if (nargin == 4) 
        % ��ô�����������
        [H W] = size(window);
        % ���ﻹ�ǽ���һ���жϣ��������Ĵ�С����̫С���������ֱȽ����ص�blocking����δ��Ĵ�С���ܱ�ͼ���
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
    % ����������ȫ����������
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

    % ����SSIM�ľ�������
    % ----------------------------------------
    C1 = (K(1)*L)^2;  % ����ʽ�ĳ�����
    C2 = (K(2)*L)^2;  % �Աȶȳ�����
    window = window / sum(sum(window)); % ��һ��
    img1 = double(img1);
    img2 = double(img2);
    
    mu1   = filter2(window, img1, 'valid'); % filter2 ��һ�������˲���������window��ϵ������img1�е����ݲ���FIR��valid��ʾ������û�в����Ե���˲����ݡ�
    mu2   = filter2(window, img2, 'valid'); % ͬ��
    mu1_sq = mu1.*mu1; % ux^2
    mu2_sq = mu2.*mu2; % uy^2
    mu1_mu2 = mu1.*mu2; % uxuy
    % ����Ĺ�ʽ�õ���D(x) = E(x^2) - E(x)^2!!
    sigma1_sq = filter2(window, img1.*img1, 'valid') - mu1_sq;
    sigma2_sq = filter2(window, img2.*img2, 'valid') - mu2_sq;
    sigma12 = filter2(window, img1.*img2, 'valid') - mu1_mu2;
    
    if (C1 > 0 & C2 > 0)
        ssim_map = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))./((mu1_sq + mu2_sq + C1).*(sigma1_sq + sigma2_sq + C2));
    else % ����Ϊ�˷�ֹC1/C2 = 0������������������ж�
        % �ֿ�������ӷ�ĸ
        numerator1 = 2*mu1_mu2 + C1;
        numerator2 = 2*sigma12 + C2;
        denominator1 = mu1_sq + mu2_sq + C1;
        denominator2 = sigma1_sq + sigma2_sq + C2;
        ssim_map = ones(size(mu1));
        index = (denominator1.*denominator2 > 0); % �����ǰѷ�ĸ>0�ľ����±�Ž���index
        ssim_map(index) = (numerator1(index).*numerator2(index))./(denominator1(index).*denominator2(index)); % �ȼ����ĸ����0������ֵ��
        index = (denominator1 ~= 0) & (denominator2 == 0); % ���denominator1��Ϊ0��denominator2Ϊ0���±�
        ssim_map(index) = numerator1(index)./denominator1(index);
        % ����D(x) = E(x^2) - E(x)^2������ֻ�ܳ���mu1_sq + mu2_sq != 0��sigma1_sq + sigma2_sq = 0�������
    end
    
    mssim = mean2(ssim_map); % ��ȡ��ֵ
    
    return
    % end ----------------------------------------