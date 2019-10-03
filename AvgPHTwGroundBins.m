%% Getting Average Plant Height per Plot Estimates
% 1. Extracting Plots from DEM
% 2. Binning Plot to get all height points for 20 bins
% 3. Extracting 3rd percentile height value from each bin
% 4. Using minumum 3rd percentile value of all bins as ground height
% 5. Subtracting all height values from ground height
% 6. Extracting 97th percentile height value from each bin
% 7. Using average of middle 12 bins and trimming 2 outlier bins to get avg height for row

% Inputs: 
    % file: File name as a charcater string for GeoTif file of DEM for field you wish to extract height from.
    % shapefile: File name as a charcater string for ESRI shapefile containing plot boundaries. Plot boundaries should encompass entire plot and allies for ground height estimation
    % bins: number of bins you wish to break up plot for boundary extraction

function [grid, means, variance, min_g] = AvgPHTwGroundBins (file, shapefile)


[DEM] = geotiffread(file(:,:,1)); % Read DEM file
DEM = im2double(DEM(:,:,1));

roi = shaperead(shapefile); % Read plot boundary shapefile
mapshow(roi); % Display plot boundaries

clearvars shapefile

bins = 20; % number of bins to break plot into

R = geotiffinfo(file); 
[x,y] = pixcenters(R); 
[X,Y] = meshgrid(x,y); % Convert x,y arrays to grid: 

clearvars R x y 

grid = zeros(length(roi), bins);
grid_g = zeros(length(roi), bins);
min_g = zeros(length(roi), 1);
means = zeros(length(roi), 1);
means_g = zeros(length(roi), 1);
variance = zeros(length(roi), 1);

%% Extracting plot
for plot = 1:4%length(roi)
    [DEMplot] = PHT_PlotSubset (DEM, roi, plot, X, Y); % Extracting plot
    
    % Divide plot into grid with X number of bins
    M = bins + 1 ; N = 1 ; %subsetting in the x direction 21 points equidistant; not subsetting in y or z direction
    rows = length(DEMplot(:,1));
    columns = length(DEMplot(1,:));
    x2 = linspace(1, columns , M) ;
    y2 = linspace(1, rows, N) ;
    
    [X2,Y2] = meshgrid(x2,y2);
    
    % Extracting ground height for each bin
    for j = 1:M - 1
        A = [X2(1,j) Y2(1,j)] ;
        B = [X2(1,j+1) Y2(1,j+1)] ;
        
        xmin = A(1);
        ymin = 1;
        xmax = B(1);
        ymax = rows;
        zmin = 0;
        zmax = inf;
        
        leftColumn = xmin;
        rightColumn = xmax;
        topLine = ymin;
        bottomLine = ymax;
        width = rightColumn - leftColumn;
        height = bottomLine - topLine;
        DEMplot_bin = imcrop(DEMplot, [leftColumn, topLine, width, height]); % crop DEM to bin coordinates
        
        grid_g(plot, j) =  prctile(DEMplot_bin(:,1), 3); %Extract 3rd percentile of each bin
    end
    
        min_g(plot, 1) = nanmin(grid_g(plot,:)); %Extract min value in grid_g to be used as the ground height for plot
        
    % Extracting average plot height
    for j = 1:M -1
        A = [X2(1,j) Y2(1,j)] ;
        B = [X2(1,j+1) Y2(1,j+1)] ;
        
        xmin = A(1);
        ymin = 1;
        xmax = B(1);
        ymax = rows;
        zmin = 0;
        zmax = inf;
        
        leftColumn = xmin;
        rightColumn = xmax;
        topLine = ymin;
        bottomLine = ymax;
        width = rightColumn - leftColumn;
        height = bottomLine - topLine;
        
        DEMdiff = DEMplot - (min_g(plot, 1)); % Subtracting ground height to DEM heigth
        DEMdiff_bin = imcrop(DEMdiff, [leftColumn, topLine, width, height]); 
        
        DEMplot_sub = DEMdiff_bin(DEMdiff_bin > 0);
        grid(plot, j) =  (prctile(DEMplot_sub(:,1), 97))*100; % Extract 97th persentile and convert from m to cm
        means(plot, 1) = (trimmean(grid(plot,5:16), 16)); % Get trimmen mean for middle twelve bins removing two extrem outliers
        variance(plot, 1) = var((grid(plot,5:16))); % Get variance estimates for middle twelve bins from plot grid
        
    end
    
    clearvars x2 y2 X2 Y2 DEMplot DEMplot_bin grid_g j A B DEMplot_sub DEMdiff_bin 

end


end
