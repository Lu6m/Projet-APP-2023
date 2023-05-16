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

%% -----------Récupération du Signal-------------%%
    [x,Fe]=audioread(audio);
    Te=1/Fe;
    [n,Pistes]=size(x);
    t=[(0:n-1)*Te];
    figure()
    plot(t,x)
    
%% ----------Stéréo en mono----------------------%%

% Si l'audio est en stéréo, alors on fait une moyenne des deux pistes pour 
% n'en obtenir plus qu'une :
    if Pistes==2
        x=mean(x,2);
    end

%% ----------Puissance Instantanée---------------%%
    disp("Pour l_audio : "+audio);
    y=[];
    ty=[];
    % On calcul la puissance instantanée de notre signal :
    PI = x.^2;
    Seuil = 0.1;
    

    for i=1:length(x)
      % Si la puissance instantanée est supérieure au seuil, on garde le 
      % point et on récupère le temps associé :
      if (PI(i)>Seuil) 
        y = [y, x(i)];
        ty = [ty, t(i)];
      end
    end

    % On enlève l'offset de notre signal
    y = y-mean(y);          


    % On augmente la taille de notre vecteur grâce à des 0 ce qui nous 
    % permettra d'avoir plus de points pour faire une fft plus précise :
    a = 40000;
    n = length(y);
    y = [y, zeros(1,a-n)];
    

%% ---------------Lissage-----------------------%%

    % Technique de moyenne mobile : chaque point est la moyenne des 120
    % valeurs suivantes (déterminé expérimentalement)
    y_new = y;
    for i = 1:n
      y_new(i) = mean(y(i:i+120));
    end
    y = y_new;


%% ------------Transformé de Fourier--------------%%
    fft_signal = fft(y);
    % On trace le signal en enlevant la partie symétrique de la TF :
    spectre = abs(fft_signal(1:a/2));                         
    frequences = Fe/((a-1)).*[0:a/2-1];


%% --------------------Tracés---------------------%%
    figure()
    subplot(2,1,1);
    % On trace le signal lissé
    plot([1:n]*Te,y(1:n))
    xlabel('Temps (s)')
    ylabel('Amplitude (mV)')
    title("Signal "+audio+" lissé")

    subplot(2,1,2);
    % On applique un filtre à la transformée de Fourier pour ne garder que 
    % les valeurs entre 0,67 et 3,167 Hz
    spectre = spectre.*(frequences>0.67).*(frequences<3.167);
    plot(frequences,spectre)
    xlabel('Fréquence (Hz)')
    ylabel('Amplitude (mV)')
    title("TF "+audio+" lissé")
    axis([0.67 3.167 min(spectre) max(spectre)])
    % On récupère le point le plus haut de notre fft
    [maxS,indMax]=max(spectre);
    % On le multiplie par 60 pour avoir le nombre de battements/min
    disp(round(frequences(indMax)*60)+" battements par minute")
end