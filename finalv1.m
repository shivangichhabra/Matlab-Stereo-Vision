
windowsize = 7;
maxdisparity = 16;
Ileft = im2double(rgb2gray(imread('tsukuba-imL.png')));
Iright = im2double(rgb2gray(imread('tsukuba-imR.png')));

[rows, columns, planes] = size(Ileft);

result = zeros(rows,columns);
ssds = zeros(rows,columns);

for i=1+windowsize:rows-windowsize
    for j=1+windowsize:columns-windowsize-maxdisparity
        bestD=0;
        bestSSD=65532;
        for d=1:maxdisparity
            patchR=Iright(i-windowsize:i+windowsize, j-windowsize:j+windowsize);
            patchL=Ileft(i-windowsize:i+windowsize, j-windowsize+d:j+windowsize+d);
            SSD = sum(sum((patchL - patchR).^2)); 
            if(SSD < bestSSD)
                bestSSD = SSD;
                bestD = d;
            end
        end
        ssds(i,j) = bestSSD;
        result(i,j)=bestD;
    end
end
result1=result/16;
figure,imshow(result1);
figure,imagesc(result);