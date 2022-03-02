%% PALA_Beamforming_SilicoPSF.m : beamforming script for simulated RF data
% Beamforms simulated RF data of the provided datasets.
% Draft implementation of a DAS (delay-and-sum) beamforming.
%
% Warning: beamformed images may be worst than those provided by Verasonics Vantage
% beamformer.
% All results and score of the article have been computed on images provided by Vantage
% beamforming. Computing metrics on this homemade beamformer may result biaised scores.
%
% Created by Alexandre Corazza, 13/10/2021, adapated by Arthur Chavignon 25/02/2020
% inspired from the function "dasmtx" of MUST toolbox www.biomecardio.com, Damien Garcia
%
% DATE 2022.03.01 - VERSION 1.1
% AUTHORS: Arthur Chavignon, Baptiste Heiles, Vincent Hingot. CNRS, Sorbonne Universite, INSERM.
% Laboratoire d'Imagerie Biomedicale, Team PPM. 15 rue de l'Ecole de Medecine, 75006, Paris
% Code Available under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (see https://creativecommons.org/licenses/by-nc-sa/4.0/)
% ACADEMIC REFERENCES TO BE CITED
% Details of the code in the article by Heiles, Chavignon, Hingot, Lopez, Teston and Couture.  
% Performance benchmarking of microbubble-localization algorithms for ultrasound localization microscopy, Nature Biomedical Engineering, 2022.
% General description of super-resolution in: Couture et al., Ultrasound localization microscopy and super-resolution: A state of the art, IEEE UFFC 2018

cd('F:\ArthurC\CHAPRO_local\_SIMULATIONS\FightClub_PostPro')
run('PALA_scripts/PALA_SetUpPaths.m')
addpath('PALA_Beamforming')
%% Select IQ and Media folder
fprintf('Running PALA_Beamforming.m\n');
workingdir = [PALA_data_folder '\PALA_data_InSilicoPSF'];cd(workingdir)
filename = 'PALA_InSilicoPSF';

myfilepath = [workingdir filesep filename];
myfilepath_RF = [workingdir filesep filename];

listVar = {'P','PData','Trans','Media','UF','Resource','TW','TX','Receive'};
load([myfilepath '_sequence.mat'],'-mat',listVar{:});Receive = Receive(1);clear listVar;

%% Load RF file
hhh=1;
load([myfilepath_RF '_RF'  num2str(hhh,'%03.0f') '.mat'],'RF','ListPos','Media','P');
RFdata=RF;clear RF

%% Beamforming parameters
PARAM.bandwidth = (Trans.Bandwidth(2)-Trans.Bandwidth(1))/Trans.frequency * 100; %bandwidth [% f0]
PARAM.f0 = Trans.frequency*1e6; %central frequency [Hz]
PARAM.fs = Receive.demodFrequency*1e6; % sampling frequency (100% bandwidth mode of Verasonics) [Hz]
PARAM.c = Resource.Parameters.speedOfSound; % speed of sound [m/s]
PARAM.wavelength = PARAM.c/PARAM.f0; % Wavelength [m]
PARAM.xe = Trans.ElementPos(:,1)/1000; % x coordinates of transducer elements [m]
PARAM.Nelements = Trans.numelements; %number of transducers
PARAM.t0 = 2*P.startDepth*PARAM.wavelength/PARAM.c - TW.peak/PARAM.f0; %time between the emission and the beginning of reception [s]

angles_list = cat(1,TX.Steer);angles_list = angles_list(1:P.numTx,1);
PARAM.angles_list = angles_list; % list of angles [rad] (in TX.Steer)
PARAM.fnumber = 1.9; % fnumber
PARAM.compound = 1; % flag to compound [1/0]

% Pixels grid (extracted from PData), in [m] 
PARAM.z = (PData(1).Origin(3)+[0:PData.Size(1)-1]*PData(1).PDelta(1))*P.Wavelength/1000;
PARAM.x = (PData(1).Origin(1)+[0:PData.Size(2)-1]*PData(1).PDelta(3))*P.Wavelength/1000;
[mesh_X,mesh_Z] = meshgrid(PARAM.x, PARAM.z);
clear angles_list

%% Beamforming
IQ = zeros([PData.Size(1:2) 1+(~PARAM.compound)*(P.numTx-1)],'single');

tic;
for ii = 1:40;%P.BlocSize%*P.numBloc
    if mod(ii,10)==0,disp(num2str(ii));end
    for iTX = 1:P.numTx % convert 100 bandiwdth data to IQ signal
        RFi = single(RFdata((iTX-1)*P.NDsample + (1:P.NDsample),:,ii));
        RF_IQ{iTX} = BF_demod100BWtoIQ(RFi);  
    end
    % Delay And Sum beamforming
    IQ(:,:,:,ii) = BF_DelayAndSum(RF_IQ, PARAM, mesh_X, mesh_Z);
end
t_end=toc;clear RFk SIG IQ_i ii %RFdata
disp([num2str(size(IQ,4)) ' frames beamformed in ' num2str(round(t_end,1)) ' sec.'])

%% Displaying IQ converted in Bmode scale
figure(1);clf
Bmode = 20*log10(abs(IQ(:,:,1,:)));Bmode = squeeze(Bmode)-max(Bmode(:)); % convert complex IQ into Bmode images
dbmax = -60; % max [dB]

im = imagesc(PARAM.x*1e3,PARAM.z*1e3,Bmode(:,:,1),[dbmax 0]);axis image; colormap gray;clb=colorbar;hold on
tt = title(['Frame ' num2str(1)]);
xlabel('x [mm]'), ylabel('z [mm]'); clb.Title.String='dB';
pp = plot(ListPos(:,1,1)*P.Wavelength,ListPos(:,3,1)*P.Wavelength,'rx','MarkerSize',10);

for ii = 1:size(Bmode,3)
    im.CData = Bmode(:,:,ii);tt.String = ['Frame ' num2str(ii)];
    pp.XData = ListPos(ii,1)*P.Wavelength;pp.YData = ListPos(ii,3)*P.Wavelength;
    pause(.1)
end

%% Compare with Vantage VSX beamforming
myfilepath_IQ = [workingdir filesep filename];
VSX_fb = load([myfilepath_IQ '_IQ'  num2str(hhh,'%03.0f') '.mat'],'IQ');

CurFig = figure(2);clf
Bmode = 20*log10(abs(IQ(:,:,1,:)));Bmode = squeeze(Bmode)-max(Bmode(:)); % convert complex IQ into Bmode images
Bmode_ref = 20*log10(abs(VSX_fb.IQ));Bmode_ref = Bmode_ref-max(Bmode_ref(:)); % convert complex IQ into Bmode images

dbmax = -60; % max [dB]

aa=tight_subplot(1,2);
axes(aa(1))
im = imagesc(PARAM.x*1e3,PARAM.z*1e3,Bmode(:,:,1),[dbmax 0]);axis image; colormap gray;clb=colorbar;hold on
tt = title(['Frame ' num2str(ii)]);
xlabel('x [mm]'), ylabel('z [mm]'); clb.Title.String='dB';
pp = plot(ListPos(1,1)*P.Wavelength,ListPos(1,3)*P.Wavelength,'rx','MarkerSize',10);

axes(aa(2))
im_ref = imagesc(PARAM.x*1e3,PARAM.z*1e3,Bmode_ref(:,:,1),[dbmax 0]);axis image; colormap gray;clb=colorbar;hold on
clb.Title.String='dB';
pp2 = plot(ListPos(1,1)*P.Wavelength,ListPos(1,3)*P.Wavelength,'rx','MarkerSize',10);title('Beamforming with Verasonics Vantage 4.4.1')
linkaxes(aa)

for ii = 1:1:size(Bmode,3)
    im.CData = Bmode(:,:,ii);
    im_ref.CData = Bmode_ref(:,:,ii);
    tt.String = ['Frame ' num2str(ii)];
    pp.XData = ListPos(ii,1)*P.Wavelength;pp.YData = ListPos(ii,3)*P.Wavelength;
    pp2.XData = ListPos(ii,1)*P.Wavelength;pp2.YData = ListPos(ii,3)*P.Wavelength;
    pause(.1)
end
