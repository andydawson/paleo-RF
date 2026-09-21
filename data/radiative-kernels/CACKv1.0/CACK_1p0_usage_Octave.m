##%% CERES Albedo Change Kernel (CACK 1.0) derivation and usage
##% See Bright and O'Halloran (in review) at GMDD for details
##
##%code tested using:
##%GNU Octave Version: 4.4.1 
##%GNU Octave License: GNU General Public License
##%Operating System: MINGW32_NT-6.2 Windows 6.2  x86_64

clear all
close all

%toolbox dependencies
pkg load netcdf
pkg load statistics
pkg load mapping

%% CACK 1.0 usage

%read file and extract variables
filename_CACK = 'CACKv1.0.nc'; %change filename as needed
info = ncinfo(filename_CACK);
lon = ncread(info.Filename,'Longitude');
lat = (ncread(info.Filename,'Latitude')); %inverted
M = (ncread(info.Filename,'Month'));
Y = (ncread(info.Filename,'Year'));
CACK_CM = ncread(info.Filename,'CACK CM');
SIG_tot_CM = ncread(info.Filename,'Sigma_total CM');
CACK = ncread(info.Filename,'CACK');
SIG_tot = ncread(info.Filename,'Sigma_total');

%% Example CACK usage for a single point

%example user-supplied input data
latitude = -7; %example on range [-90 90]
longitude = -65; %example on range [-180 180]
%delta_albedo = [0.34 0.3 0.25 0.2 0.05 0.05 0.05 0.1 0.25 0.3 0.3 0.4]'; %example monthly albedo perturbation on range [-1 1]
delta_albedo = 0.01.*[0.06 0.06 0.06 0.06 0.06 0.06 0.06 0.06 0.06 0.06 0.06 0.06]'; %example monthly albedo perturbation on range [-1 1]
delta_albedo_unc = delta_albedo.*0.01; %assume 1% uncertainty for simplicity

% extract CACK for neareast point and calculate TOA RF for each observation

%nearest neighbor interpolation of monthly cack at the nearest model grid to the example point
latind = interp1(lat,1:length(lat),latitude,'nearest');
lonind = interp1(wrapTo180(lon),1:length(lon),longitude,'nearest'); %note reprojecting longitude to [-180 180] using wrapTo180

% climatology version for single year example
cack_cm_p = squeeze(CACK_CM(latind,lonind,1:12)); %extract appropriate value for the point
cack_cm_p_unc = squeeze(SIG_tot_CM(latind,lonind,1:12)); %extract appropriate value for the point
RF_cm_p_monthly = delta_albedo .* -cack_cm_p; %Bright & O'Halloran Equation 4 
RF_cm_p_monthly_unc = abs(RF_cm_p_monthly).*sqrt((delta_albedo_unc./delta_albedo).^2 + (cack_cm_p_unc./cack_cm_p).^2);
fprintf('annual RF is %4.2f +/- %4.2f W m^-2.\n',nanmean(RF_cm_p_monthly),nanmean(RF_cm_p_monthly_unc))

% annual version for multi-year RF from constant delta albedo
cack_p = squeeze(CACK(latind,lonind,:,:)); %extract appropriate value for the point
cack_p_unc = squeeze(SIG_tot(latind,lonind,:,:)); %extract appropriate value for the point
RF_p_monthly = repmat(delta_albedo,1,length(Y)) .* -cack_p; %Bright & O'Halloran Equation 4 
RF_p_monthly_unc = abs(RF_p_monthly).*sqrt((repmat(delta_albedo_unc,1,length(Y))./repmat(delta_albedo,1,length(Y))).^2 + (cack_p_unc./cack_p).^2);
RF_p = nanmean(RF_p_monthly,1); %average over months for annual means
RF_p_unc = nanmean(RF_p_monthly_unc,1); %average over months for annual means

figure
plot(1:12,RF_cm_p_monthly,'b-o')
hold on
plot(1:12,RF_cm_p_monthly-RF_cm_p_monthly_unc,'r--')
plot(1:12,RF_cm_p_monthly+RF_cm_p_monthly_unc,'r--')
xlabel('Month')
ylabel('Radiative Forcing (W m^-^2)')
title('Monthly TOA SW radiative forcing using CACK climatology')

figure
plot(Y+2000,RF_p,'k-o')
hold on
plot(Y+2000,RF_p-RF_p_unc,'m--')
plot(Y+2000,RF_p+RF_p_unc,'m--')
ylabel('Radiative Forcing (W m^-^2)')
title('Annual TOA SW radiative forcing using annual CACK')


