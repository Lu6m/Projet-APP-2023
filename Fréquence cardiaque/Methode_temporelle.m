close all
clc
ECG("100.wav")
ECG("101.wav")
ECG("102.wav")
ECG("103.wav")
ECG("104.wav")
ECG("105.wav")
ECG("106.wav")
ECG("107.wav")
ECG("108.wav")
ECG("109.wav")


function ecg=ECG(audio)
%% -----------Récupération du Signal-------------
    [x,Fe]=audioread(audio);
    Te=1/Fe;
    [n,Pistes]=size(x);
    t=[(0:n-1)*Te];
    

%% ----------Stéréo en mono----------------------

% Si l'audio est en stéréo, alors on fait une moyenne des deux pistes pour 
% n'en obtenir plus qu'une :
    if Pistes==2
        y=mean(y,2);
    end

%% ----------Récupération Signal Découpé---------------
    Seuil=0.2;
    y=[];
    ty=[];
    % On ne garde que les valeurs dont l'amplitude est supérieure au seuil
    % On garde avec, le temps associé à chaque point 
    for i=1:n-1
        if x(i)>Seuil;
            y=[y x(i)];
            ty=[ty t(i)];
        end
    end

%% ----------------------Tracés------------------------
    figure()
    subplot(2,1,1)
    plot(t,x)
    xlabel('Temps (s)')
    ylabel('Amplitude (mV)')
    title("Signal : "+audio)
    axis([0,n*Te,-0.3,max(x)+0.2])
    subplot(2,1,2)
    plot(ty,y)


%% ---------------Trouver les pics------------------
    disp("Pour l'audio : "+audio);
    findpeaks(y,"MinPeakDistance",200,"MinPeakHeight",0.8);
    % On récupère les valeurs des pics, leur amplitude et indice
    [voltage,indice]=findpeaks(y,"MinPeakDistance",200,"MinPeakHeight",0.8);
    % On calcul le nombre de pics du signal
    nbPeaks=length(indice);
    % On trouve le temps associé à chaque pic
    temporel=ty(indice);

%% ---------Calculer la fréquence cardiaque---------------
    % On calcule la fréquence cardiaque moyenne 
    bpm=round((nbPeaks-1)*60/(temporel(nbPeaks)-temporel(1)));
    disp ("Moyenne = "+bpm+" battements par minute");
    xlabel('Points')
    ylabel('Amplitude (mV)')
    title("Detection des "+nbPeaks+" pics")

    % On calcule la fréquence cardiaque au cours du temps
    for j=1:nbPeaks-1
        deltat=temporel(j+1)-temporel(j);
        deltaf=1/deltat;
        bpmm=60*deltaf;
        disp ("Fréquence cardiaque : "+round(bpmm)+" battements par minutes");
    end 
end