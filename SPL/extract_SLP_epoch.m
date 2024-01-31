
function [I1,I2,I3,I4] = extract_SLP_epoch(pathin, plot_time, xlimsdis,offset,baseline_SPL,sdur,edur,plotid,answer)
    
    [signal_var, fs] = audioread(pathin);
    
    newFs = 8000;
    d = designfilt('bandpassiir','FilterOrder',6,...
             'HalfPowerFrequency1',31.8,...
             'HalfPowerFrequency2',newFs,...
             'SampleRate', fs,'DesignMethod','butter');
    
   signal_var = filtfilt(d,signal_var);

    if(plot_time)    
    subplot(3,2,1 + plotid*2)
        plot(signal_var)
        xlim(xlimsdis*fs)
    end

    start = offset + 8*fs;
    
    if(plot_time)
        xline(offset)
    end


    signal_var = signal_var(start:end);
    
    signal_var = buffer(signal_var,sdur*fs,0);
    signal_var = signal_var(1:end-2*fs,2:5);
    signal_var = signal_var(:);
    signal_var = buffer(signal_var,fs/250,0);
    signal_var =rms(signal_var,'omitnan');
    signal_var = 20*log10(signal_var/baseline_SPL);
    signal_var = buffer(signal_var, edur*250, 0);
        
    I1 = mean(signal_var(:,answer == 1),2);
    I2 = mean(signal_var(:,answer == 2),2);
    I3 = mean(signal_var(:,answer == 3),2);
    I4 = mean(signal_var(:,answer == 4),2);
    
    N = length(I4);
    t = linspace(0,N/250,N);
    
    if(plot_time)

        subplot(3,2,2 + plotid*2)
        hold on
    
        plot(t,movmean(I1,25))
        plot(t,movmean(I2,25))
        plot(t,movmean(I3,25))
        plot(t,movmean(I4,25))
       
        legend('1','2','3','4','Location','west');
    end
    I1 = movmean(I1,25);
    I2 = movmean(I2,25);
    I3 = movmean(I3,25);
    I4 = movmean(I4,25);
end