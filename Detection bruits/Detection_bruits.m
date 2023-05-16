%% Remarques du tuteur avant correction
%{
---------------------------------------------------------------------------
G9A
- Le code fonctionne
- Structure du code a ameliorer (parametres utilisateurs a placer en amont)
- Aucun commentaire !!
- Usage du calcul matriciel 
- Vecteur temps bien defini
- Calcul puissances instantanee a revoir (difficile a comprendre !!)
- Formule du seuil de la puissance instantanee non ecrit !!
- Determination des plages de bruit a revoir (mais presque bonne)
- Duree de chaque plage de bruit non calculee
- Tension RMS de chaque plage de bruit calculee (mais formule puissance
moyenne a revoir)
- Calcul de la Puissance moyenne de chaque plage difficile a comprendre
- Autocorrelation bien programmee, mais maximum d'autocorrelation et delai associe non
programmes
- Methode testee sur 3/4 fichiers, boucle a utiliser pour simplifier
- Parametres a identifier et placer en amont du code
- Figures de resultats claires
---------------------------------------------------------------------------
%}


%% PROGRAMME MODIFIE
close all

% <Choix du fichier
disp(" ");
disp('Veuillez saisir le numéro du fichier que vous souhaitez traiter :');
disp(" ");
fprintf('1. Jardin01.mp3\n2. Jardin02.mp3\n3. MarteauPiqueur01.mp3\n4. Ville01.mp3\n \n');
choix = input("Votre choix : ");
if choix == 1
    audio='Jardin01.mp3';
elseif choix == 2
    audio='Jardin02.mp3';
elseif choix == 3
    audio='MarteauPiQueur01.mp3';
elseif choix == 4
    audio='Ville01.mp3';
else
    disp("Ce choix n'existe pas");
    return
end
% />
        
ANALYSE(audio);

function analyse=ANALYSE(audio)
    % ANALYSE prend en entrée le titre d'un fichier audio (str) et isole
    % les bruits pénibles selon les conditions du probleme 1, ainsi que
    % leurs puissances, leurs tensions RMS et leurs coef d'autocorrelation.
    
    % <Parametres de l'enonce
    G = 30;
    P0 = 20e-6;
    S_dbv = -48;
    P_SPL = 80;
    % />
    % <Calcul du seuil
    Seuil = 10*log10((((10^(G/20))*P0*(10^(P_SPL/20))*(10^(S_dbv/20)))^2)*10^3);
    Seuil= round(Seuil);
    % />
    [y, Fe] = audioread(audio);
    Te=1/Fe;
    [n,Pistes]=size(y);
    t=(0:n-1)*Te;
    dt=0.5; %duree minimale d'un silence (secondes)
    Dt=1; %duree minimale d'un bruit (secondes)
    tinc=0.1; %parcours du signal tous les tinc pour détecter dt ou Dt

    if Pistes==2
        y=mean(y,2);
    end
    
    
    duree=length(y)/Fe;
    debut=1; 
    nbEchantSeg=Fe*tinc; % nombre d'echantillons
    fin=duree*Fe-nbEchantSeg; % fin du bruit
    compteurseg=0; 
    compteurseg2=0; 
    L=[];

    while debut<fin 
        % <Calcul de la puissance instantanee
        Pi = (1/nbEchantSeg) * sum(y(debut:debut+nbEchantSeg).^2);
        PidBm=10*log10(Pi*10^3);
        % />
        if PidBm>Seuil

            compteurseg=compteurseg+1;
            deb=debut-compteurseg2*Fe*tinc; 
            debS=deb/Fe;

            if debS<dt
                 debS=0;
            end

            finS=debut/Fe; 

            Pbruit=0;
            for j=deb:debut
                Pbruit=Pbruit+y(j)^2;
                y2(j)=0;
            end            
            compteurseg2=0;
        else
            compteurseg2=compteurseg2+1; 
            if compteurseg>Dt/tinc
                deb=debut-compteurseg*Fe*0.1;
                debS=deb/Fe;
                finS=debut/Fe;
   
                if deb==1
                    L=[L;debut]; 
                
                else
                  L=[L;deb];
                  L=[L;debut]; 
                end            
                
    
                Pbruit=0;
                for j=deb:debut
                    Pbruit=Pbruit+y(j)^2;
                end
                % <Puissance, tension RMS, et coef intercor du bruit
                Pbruit=Pbruit/(debut-deb);
                DB=10*log10(Pbruit)+30; % conversion dBm
                RMS=sqrt(Pbruit);
                r=[y(deb:debut)',zeros(1,n+debut-deb)];
                % />
                disp("-----------------------------------------------------");
                disp("Bruit fort détecté de "+debS+" à "+finS +" s | Durée : "+(finS-debS)+" s");
                disp("Puissance : "+DB+" dBm | Tension RMS : "+RMS+" V");
                disp("Coefficient d'autocorrélation : "+max(r));
                disp("-----------------------------------------------------");
            end
            compteurseg=0;
        end
    
        debut=debut+Fe*tinc; 
        
    end
    
    % <Courbe indicative bruit
    y3 = zeros(1,length(y));
    for i = 1:2:length(L)
        y3(L(i):L(i+1)) = dt;
    end
    % />
    
    figure
    plot(t,y);
    xlabel('Temps')
    ylabel('Signal audio')
    title(audio + " en fonction du temps")
    hold on
    plot(t,y3,'r')
    legend("audio d'origine","approximation des bruits et silences")
end

%% Remarques du tuteur avant correction
%%% Les figures sont claires, c'est appreciable !
%%% Jardin 2 : 7 plages attendues
%%% Jardin 1 & Marteau Piqueur ok
%%% Formules utilisees difficiles a comprendre !!!!!!!!!
%%% Difference entre les figures et les calculs !! Par exemple pour jardin
%%% 1, il n'y a qu'un seul calcul attendu !!

%% Liste non exhaustive des modifications apportees par G9A apres revision
% - Ajout d'une sélection de fichier a traiter (l.29)
% - Utilisation des bons fichiers audio
% - Ajout de description pour ANALYSE (l.52)
% - Clarification de certaines variables avec commentaires
% - Ajout du calcul du seuil a partir des parametres de l'enonce 
%   (l.56 & 62)
% - Retrait de parties du code redondantes et inutiles
% - Calcul plus simple de la duree (l.79)
% - Calcul de la puissance instantanee plutot que puissance moyenne (l.88)
% - Calcul du coef d'autocorrelation pour remplacer la fonction xcorr
%   (l.134)
% - Clarification de l'affichage des resultats, ajout de la duree du bruit
%   (l.136)
% - Simplification de y3 par calcul matriciel (l.164)
%--------------------------------------------------------------------------
% Probleme non corrige : une plage de trop pour Jardin02, sais pas pourquoi