%% Calib1: Calibracion con monitor
% 0 - 21s oido izquierdo. Chan 2
% 21s - 53s oido derecho. Chan 3
[c1_ch2, fs] = audioread("D:\shared_git\MaestriaThesis\SLP_data\calib1 1-2.wav");
[c1_ch3, ~] = audioread("D:\shared_git\MaestriaThesis\SLP_data\calib 1-3.wav");
newFs = fs/2;

d = designfilt('bandpassiir','FilterOrder',6,...
         'HalfPowerFrequency1',31.8,...
         'HalfPowerFrequency2',newFs,...
         'SampleRate', fs,'DesignMethod','butter');

c1_ch2=filtfilt(d,c1_ch2);
c1_ch3=filtfilt(d,c1_ch3);

N = length(c1_ch2);
t = linspace(0,N/fs,N);

c1_ch2 = c1_ch2(t<20 & t>1);
c1_ch2 =buffer(c1_ch2,0.125*fs,0);
c1_ch2=rms(c1_ch2,'omitnan');
c1_ch2=median(c1_ch2);
c1_ch2=c1_ch2./(10.^(94/20));

c1_ch3 = c1_ch3(t>22 & t<52);
c1_ch3 =buffer(c1_ch3,0.125*fs,0);
c1_ch3=rms(c1_ch3,'omitnan');
c1_ch3=median(c1_ch3);
c1_ch3=c1_ch3./(10.^(94/20));

% calib2: Calibracion binaural con audifonos razer
% 0 - 14s audifono izquierdo. Chan 2 
% 14 - 31 audifono derecho. Chan 3 
[c2_ch2, fs] = audioread("D:\shared_git\MaestriaThesis\SLP_data\calib2-02.wav");
[c2_ch3, ~] = audioread("D:\shared_git\MaestriaThesis\SLP_data\calib2-03.wav");

c2_ch2=filtfilt(d,c2_ch2);
c2_ch3=filtfilt(d,c2_ch3);

N = length(c2_ch2);
t = linspace(0,N/fs,N);

c2_ch2 = c2_ch2(t>1 & t<13);
c2_ch2 =buffer(c2_ch2,0.125*fs,0);
c2_ch2=rms(c2_ch2,'omitnan');
c2_ch2=median(c2_ch2);
c2_ch2=c2_ch2./(10.^(94/20));

c2_ch3 = c2_ch3(t>15 & t<30);
c2_ch3 =buffer(c2_ch3,0.125*fs,0);
c2_ch3=rms(c2_ch3,'omitnan');
c2_ch3=median(c2_ch3);
c2_ch3=c2_ch3./(10.^(94/20));
% calib3: Calibracion microfono 4
% 0 - 14s audifono izquierdo. Chan 4
[c3_ch4, fs] = audioread("D:\shared_git\MaestriaThesis\SLP_data\calib3-04.wav");

c3_ch4=filtfilt(d,c3_ch4);

N = length(c3_ch4);
t = linspace(0,N/fs,N);

c3_ch4 = c3_ch4(t<20 & t>1);
c3_ch4 =buffer(c3_ch4,0.125*fs,0);
c3_ch4=rms(c3_ch4,'omitnan');
c3_ch4=median(c3_ch4);
c3_ch4=c3_ch4./(10.^(94/20));

%% 
[PN_medio_left, fs] = audioread("D:\shared_git\MaestriaThesis\SLP_data\ruidorosa_medio-02.wav");
PN_medio_left = filtfilt(d,PN_medio_left);
PN_medio_left = buffer(PN_medio_left,0.125*fs,0);
PN_medio_left =rms(PN_medio_left,'omitnan');
PN_medio_left = median(PN_medio_left);
PN_medio_left = 20*log10(PN_medio_left/c1_ch2);

[PN_medio_right, ~] = audioread("D:\shared_git\MaestriaThesis\SLP_data\ruidorosa_medio-03.wav");
PN_medio_right = filtfilt(d,PN_medio_right);
PN_medio_right = buffer(PN_medio_right,0.125*fs,0);
PN_medio_right =rms(PN_medio_right,'omitnan');
PN_medio_right = median(PN_medio_right);
PN_medio_right = 20*log10(PN_medio_right/c1_ch3);


[PN_alto_left, ~] = audioread("D:\shared_git\MaestriaThesis\SLP_data\ruidorosa_max-02.wav");
PN_alto_left = filtfilt(d,PN_alto_left);
PN_alto_left = buffer(PN_alto_left,0.125*fs,0);
PN_alto_left =rms(PN_alto_left,'omitnan');
PN_alto_left = median(PN_alto_left);
PN_alto_left = 20*log10(PN_alto_left/c1_ch2);

[PN_alto_right, ~] = audioread("D:\shared_git\MaestriaThesis\SLP_data\ruidorosa_max-03.wav");
PN_alto_right = filtfilt(d,PN_alto_right);
PN_alto_right = buffer(PN_alto_right,0.125*fs,0);
PN_alto_right =rms(PN_alto_right,'omitnan');
PN_alto_right = median(PN_alto_right);
PN_alto_right = 20*log10(PN_alto_right/c1_ch3);


































