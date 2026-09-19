CESM 1.1.1 Radiative kernels 
Angeline G Pendergrass (apgrass@ucar.edu) 
June 2017

-----------------------------------------------------------------
For more scripts and to check for updates, visit 
https://github.com/apendergrass/cam5-kernels
-----------------------------------------------------------------

QUICK START:

ncl scripts/calcp.ncl 
ncl scripts/calcdq1k.ncl 
matlab -nosplash -nodesktop -r "addpath ./scripts; kernel_demo"

Once you've run a test using the demo, you can replace the demo with your own changes in temperature and moisture. 

-----------------------------------------------------------------
-----------------------------------------------------------------

CONTENTS

* Kernels (./kernels)
-alb.kernel.nc: Albedo (SW)
-ts.kernel.nc : Surface temperature (LW)
-t.kernel.nc  : Air temperature (LW)
-q.kernel.nc  : Moisture kernel (LW and SW)
-PS.nc        : Surface pressure from CESM simulation used to calculate kernels 

* Radiative forcing (./forcing) 
-aerosol.forcing.nc: Aerosol forcing (LW and SW)
-ghg.forcing.nc    : Greenhouse gas forcing (LW and SW)

* Demo data files (./demodata): Generated from the year of CESM simulation for the kernels (2006/7) and for forcing (2096/7)
-basefields.nc  : Base state temperature, moisture, and radiative fluxes 
-changefields.nc: Example changes in temperature, moisture, and radiative fluxes 

* Scripts (./scripts)
-calcp.ncl: Calculate 3-d pressure fields from PS.nc and hybrid-sigma coordinate info in t.kernel.nc
-calcdq1k.ncl: Given a base moisture, temperature, and pressure field, calculate the change in moisture for 1 K warming at constant relative humidity
-kernel_demo.m: Given changes in temperature, moisture, and surface shortwave radiation (net and downwelling), calculate TOA climate feedbacks  

* Additional scripts at https://github.com/apendergrass/cam5-kernels 
-Convert kernels to standard CMIP5 pressure levels
-Demo on CMIP5 pressure levels
-Decompose the temperature feedback in to Planck and lapse rate components
-Calculate cloud feedback
-Logarithmic moisture (rather than linear)

-----------------------------------------------------------------
-----------------------------------------------------------------

RADIATIVE FLUX VARIABLE DESCRIPTIONS

FLNS : Net Longwave Flux at Surface, all-sky   (positive: up)
FLNSC: Net Longwave Flux at Surface, Clear-sky (positive: up)
FLNT : Net Longwave Flux at Top-of-atmosphere, all-sky (positive: up)
FLNTC: Net Longwave Flux at Top-of-atmosphere, Clear-sky (positive: up)
FSNS : Net Shortwave Flux at Surface, all-sky (positive: down)
FSNSC: Net Shortwave Flux at Surface, Clear-sky (positive: down)
FSNT : Net Shortwave Flux at Top-of-atmosphere, all-sky (positive: down)
FSNTC: Net Shortwave Flux at Top-of-atmosphere, Clear-sky (positive: down)
