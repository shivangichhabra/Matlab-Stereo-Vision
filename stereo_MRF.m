function [ result2 ] = stereo_MRF(Left_image,Right_image )
LEFT = 1;
RIGHT = 2;
UP = 3;
DOWN = 4;
DATA = 5;

maxdisparity = 16;
Iterations = 20;
Lamda = 20;
Trunc = 2;
windowsradius = 2;

Ileft = double(rgb2gray(Left_image));
Iright = double(rgb2gray(Right_image));
[rows, columns] = size(Ileft);

grid = zeros(rows,columns,DATA,maxdisparity);
result = zeros(rows,columns);

fprintf ('Generating DATA\n');

for x=1+windowsradius:rows-windowsradius
    for y=1+windowsradius+maxdisparity:columns-windowsradius
        for label=1:maxdisparity
            patchR=Iright(x-windowsradius:x+windowsradius, y-windowsradius-label:y+windowsradius-label);
            patchL=Ileft(x-windowsradius:x+windowsradius, y-windowsradius:y+windowsradius);
            grid(x,y,DATA,label) = sum(sum(imabsdiff(patchL,patchR)))/((windowsradius*2+1)*(windowsradius*2+1));
        end
    end
end


for iter = 1:Iterations
    
    fprintf ('Running %d Iteration\n',iter);
    
    % belief propogation RIGHT
    for x=1:rows
        for y=1:columns-1
            new_msg = zeros(maxdisparity,1);
            
            for i=1:maxdisparity
                minval=intmax;
                for j=1:maxdisparity
                    temp = Lamda * min(abs(i-j),Trunc);
                    temp = temp + grid(x,y,DATA,j);
                    temp = temp + grid(x,y,LEFT,j);
                    temp = temp + grid(x,y,UP,j);
                    temp = temp + grid(x,y,DOWN,j);
                    minval=min(minval,temp);
                end
                new_msg(i)=minval;
            end
            
            for i=1:maxdisparity
                grid(x,y+1,LEFT,i)=new_msg(i);
            end
            
        end
    end
    
    
    
    
    % belief propogation LEFT
    for x=1:rows
        for y=columns:2
            new_msg = zeros(maxdisparity,1);
            
            for i=1:maxdisparity
                minval=intmax;
                for j=1:maxdisparity
                    temp = Lamda * min(abs(i-j),Trunc);
                    temp = temp + grid(x,y,DATA,j);
                    temp = temp + grid(x,y,RIGHT,j);
                    temp = temp + grid(x,y,UP,j);
                    temp = temp + grid(x,y,DOWN,j);
                    minval=min(minval,temp);
                end
                new_msg(i)=minval;
            end
            
            for i=1:maxdisparity
                grid(x,y-1,RIGHT,i)=new_msg(i);
            end
            
        end
    end
    
    
    
    % belief propogation UP
    for y=1:columns
        for x=1:rows-1
            new_msg = zeros(maxdisparity,1);
            
            for i=1:maxdisparity
                minval=intmax;
                for j=1:maxdisparity
                    temp = Lamda * min(abs(i-j),Trunc);
                    temp = temp + grid(x,y,DATA,j);
                    temp = temp + grid(x,y,LEFT,j);
                    temp = temp + grid(x,y,RIGHT,j);
                    temp = temp + grid(x,y,DOWN,j);
                    minval=min(minval,temp);
                end
                new_msg(i)=minval;
            end
            
            for i=1:maxdisparity
                grid(x+1,y,DOWN,i)=new_msg(i);
            end
            
        end
    end
    
    
    
    
    % belief propogation DOWN
    for y=1:columns
        for x=rows:2
            new_msg = zeros(maxdisparity,1);
            
            for i=1:maxdisparity
                minval=intmax;
                for j=1:maxdisparity
                    temp = Lamda * min(abs(i-j),Trunc);
                    temp = temp + grid(x,y,DATA,j);
                    temp = temp + grid(x,y,LEFT,j);
                    temp = temp + grid(x,y,RIGHT,j);
                    temp = temp + grid(x,y,UP,j);
                    minval=min(minval,temp);
                end
                new_msg(i)=minval;
            end
            
            for i=1:maxdisparity
                grid(x-1,y,UP,i)=new_msg(i);
            end
            
        end
    end
    
    
    for x=1:rows
        for y=1:columns
            best= intmax;
            
            for j=1:maxdisparity
                cost = grid(x,y,LEFT,j);
                cost = cost + grid(x,y,RIGHT,j);
                cost = cost + grid(x,y,UP,j);
                cost = cost + grid(x,y,DOWN,j);
                cost = cost + grid(x,y,DATA,j);
                
                if(cost < best)
                    best = cost;
                    result(x,y) = j;
                end
            end
        end
    end
    
    result2=result/maxdisparity;
    
    
end
figure,imshow(result2);
figure,imagesc(result);
end


