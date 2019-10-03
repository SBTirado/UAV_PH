# UAV_PH
Extract mean plot plant height values from DEMs created from maize nursery fields.

Usage:
[grid, means, variance, min_g] = AvgPHTwGroundBins (file, shapefile)

Inputs: 

     file: File name as a charcater string for GeoTif file of DEM for field you wish to extract height from.
     
     shapefile: File name as a charcater string for ESRI shapefile containing plot boundaries. Plot boundaries should encompass entire plot and allies for ground height estimation
     
     bins: number of bins you wish to break up plot for boundary extraction

Summary:
 1. Extracting Plots from DEM
 2. Binning Plot to get all height points for 20 bins
 3. Extracting 3rd percentile height value from each bin
 4. Using minumum 3rd percentile value of all bins as ground height
 5. Subtracting all height values from ground height
 6. Extracting 97th percentile height value from each bin
 7. Using average of middle 12 bins and trimming 2 outlier bins to get avg height for row
