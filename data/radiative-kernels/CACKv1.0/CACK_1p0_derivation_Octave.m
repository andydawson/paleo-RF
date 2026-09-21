%% CERES Albedo Change Kernel (CACK 1.0) derivation and usage
% See Bright and O'Halloran (in review) at GMDD for details

%code tested using:
%GNU Octave Version: 4.4.1 
%GNU Octave License: GNU General Public License
%Operating System: MINGW32_NT-6.2 Windows 6.2  x86_64

clear all
close all

%toolbox dependencies
pkg load netcdf
pkg load statistics
pkg load mapping

file_path = fileparts(mfilename('fullpath')); %directory where script is located
cd(file_path)

%year_flag = 1; %specify 1 to use the 15-year mean climatology or a specific year between 2001 and 2016, inclusive
%note the input data must include the years specified
year_flag = 2017; %to specify a single year

% input data are available for download from:
% https://ceres.larc.nasa.gov/products.php?product=EBAF-TOA
% save input files and script in same directory
% the example data are for 2017 only
filename_TOA = 'CERES_EBAF-TOA_Ed4.0_Subset_201701-201712.nc'; %change filename as needed
filename_SFC = 'CERES_EBAF-Surface_Ed4.0_Subset_201701-201712.nc';% change filename as needed

%% CACK 1.0 derivation
% Read CERES EBAF 4.0 data, calculate system parameters, and calculate
% kernel

%read file info
info_sfc = ncinfo(filename_SFC);
info_toa = ncinfo(filename_TOA);
%extract data
toa_solar = ncread(info_toa.Filename,'solar_mon');
cereslon = ncread(info_sfc.Filename,'lon');
cereslat = ncread(info_sfc.Filename,'lat');
sfc_up = ncread(info_sfc.Filename,'sfc_sw_up_all_mon');
sfc_down = ncread(info_sfc.Filename,'sfc_sw_down_all_mon');

% make time stamp variables
time = ncread(info_sfc.Filename,'time');
starttime = datenum('2000-03-01 00:00:00');
serdate = double(starttime+time);
[Y,M,D,H,Mn,S] = datevec(serdate);

% make climatology or use a single year
if year_flag==1 %make a climatology (mean) of 2001-2016
    for m = 1:12
        inds = M==m & (Y>=2001 & Y<=2016);
        SWdown_sfc_CERES(:,:,m) = nanmean(sfc_down(:,:,inds),3);
        Solar_CERES(:,:,m) = nanmean(toa_solar(:,:,inds),3);
    end
    
else %use a single year
    for m = 1:12
        inds = M==m & (Y==year_flag);
        SWdown_sfc_CERES(:,:,m) = nanmean(sfc_down(:,:,inds),3);
        Solar_CERES(:,:,m) = nanmean(toa_solar(:,:,inds),3);
    end
end
%calculate clearness index
T_CERES = SWdown_sfc_CERES./Solar_CERES; %Clearness Index, see Table 1
%calculate CACK
cack = SWdown_sfc_CERES.*(T_CERES.^0.5); %Bright and O'Halloran Equation 17

figure
pcolor(cereslon,cereslat,cack(:,:,1)')
shading flat
colorbar
title('CACK, January (W m^-^2)')
