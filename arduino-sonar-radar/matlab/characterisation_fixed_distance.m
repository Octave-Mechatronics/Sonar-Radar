%% Sensor-Charakterisierung: Praezision bei fester, bekannter Distanz
% Datenquelle: data/messung_20cm.csv (Spalten: index, abstand_cm)
% -> 100 Wiederholungsmessungen des HC-SR04 bei fest stehendem Servo,
%    Objekt in bekannter realer Distanz.

clear; clc; close all;

% Pfade relativ zum Skript aufloesen (funktioniert unabhaengig davon, aus
% welchem Ordner MATLAB gerade laeuft - kein fest einprogrammierter Pfad
% wie 'C:\Users\...' noetig)
scriptDir  = fileparts(mfilename('fullpath'));
dataDir    = fullfile(scriptDir, '..', 'data');
resultsDir = fullfile(scriptDir, '..', 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

realDistance = 20.0;  % [cm] mit dem Lineal gemessene tatsaechliche Distanz -- ANPASSEN!

%% Daten einlesen
T = readtable(fullfile(dataDir, 'messung_20cm.csv'));
d = T.abstand_cm;
n = height(T);

%% Kennwerte berechnen
meanD  = mean(d);              % Mittelwert -> zeigt die "typische" Anzeige
stdD   = std(d);                % Standardabweichung -> Streuung/Praezision
minD   = min(d);
maxD   = max(d);
spanD  = maxD - minD;           % Spannweite
biasD  = meanD - realDistance;  % systematischer Fehler (Bias) ggue. realDistance

fprintf('n = %d Messungen\n', n);
fprintf('Mittelwert            = %.3f cm\n', meanD);
fprintf('Standardabweichung    = %.3f cm\n', stdD);
fprintf('Min / Max              = %.2f / %.2f cm\n', minD, maxD);
fprintf('Spannweite (Max-Min)  = %.3f cm\n', spanD);
fprintf('Systematischer Fehler  = %.3f cm  (Mittelwert - reale Distanz)\n', biasD);

%% Grafik: Messreihe mit realer Referenzdistanz
figure;
plot(T.index, d, 'o-', 'MarkerFaceColor', 'b');
yline(realDistance, '--r', 'reale Distanz');
xlabel('Messung Nr.');
ylabel('gemessener Abstand [cm]');
title('HC-SR04: Wiederholungsmessung bei fester Distanz');
grid on;
saveas(gcf, fullfile(resultsDir, 'characterisation_20cm_reihe.png'));

%% Grafik: Histogramm der Messwerte
figure;
histogram(d, 10);
xlabel('gemessener Abstand [cm]');
ylabel('Haeufigkeit');
title('Verteilung der Messwerte');
grid on;
saveas(gcf, fullfile(resultsDir, 'characterisation_20cm_histogramm.png'));
