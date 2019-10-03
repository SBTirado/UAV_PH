%%%% Subsetting GeotTiff image to desired ROI
% % Inputs:
    % DEM: Digital Elevation Model for field
    % roi: Plot boundaries
    % plot: plot number as indicated by row on plot boundary shapefile
    % X & Y: Grids for spatial coordinates of DEM

function [DEMplot] = PHT_PlotSubset (DEM, roi, plot, X, Y)

% Remove trailing nan from shapefile
rx = roi(plot).X(1:end-1);
ry = roi(plot).Y(1:end-1);

% Create Mask
mask_area = inpolygon(X,Y,rx,ry); 

clearvars rx ry;

% Apply mask to orthomosaic
DEMplot = bsxfun(@times, DEM, mask_area);

% Get coordinates of the boundary of the region
structBoundaries = bwboundaries(mask_area);
x = structBoundaries{1}(:, 2); % Columns of n by 2 array of x,y coordinates
y = structBoundaries{1}(:, 1); % Rows of n by 2 array of x,y coordinates

clearvars mask_area structBoundaries;

% Crop the image to keep only region of interest
leftColumn = min(x);
rightColumn = max(x);
topLine = min(y);
bottomLine = max(y);
width = rightColumn - leftColumn;
height = bottomLine - topLine;
DEMplot = imcrop(DEMplot, [leftColumn, topLine, width, height]);


