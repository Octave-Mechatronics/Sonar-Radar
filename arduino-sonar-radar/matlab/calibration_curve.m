%% HC-SR04 Kennlinie: Messgenauigkeit ueber verschiedene reale Distanzen (Versuch 2)
% Erwartet fuer JEDE Distanz in realDistances eine EIGENE Datei:
%   data/messung_<D>cm.csv   (Spalten: index, abstand_cm)
% z.B. data/messung_10cm.csv, data/messung_20cm.csv, ...
%
% Jede Datei wird separat mit src/sensor_characterization.ino aufgenommen
% (Servo bleibt fest, Objekt jeweils auf die entsprechende reale Distanz
% gestellt) - NICHT von Hand in einer CSV zusammenkopieren. Das Skript
% hier liest alle Dateien ein und baut daraus die Kennlinie.

clear; clc; close all;

scriptDir  = fileparts(mfilename('fullpath'));
dataDir    = fullfile(scriptDir, '..', 'data');
resultsDir = fullfile(scriptDir, '..', 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

% Reale Referenzdistanzen, fuer die jeweils eine Messdatei existieren muss
realDistances = [10 15 20 25 30 40 50 60 80 100];  % [cm] -- ANPASSEN

n = numel(realDistances);
meanMeasured = nan(n,1);
stdMeasured  = nan(n,1);
nSamples     = nan(n,1);

%% Jede Datei einzeln einlesen und Kennwerte berechnen
for i = 1:n
    fname = fullfile(dataDir, sprintf('messung_%dcm.csv', realDistances(i)));
    T = readtable(fname);
    meanMeasured(i) = mean(T.abstand_cm);
    stdMeasured(i)  = std(T.abstand_cm);
    nSamples(i)     = height(T);
end

%% Zusammenfassungstabelle (eine Zeile pro Distanz)
summary = table(realDistances(:), meanMeasured, stdMeasured, nSamples, ...
    'VariableNames', {'reale_distanz_cm', 'mittelwert_cm', 'stdabw_cm', 'n'});
disp(summary);
writetable(summary, fullfile(resultsDir, 'calibration_summary.csv'));

%% Lineare Kalibrierung: gemessen = a * real + b
p = polyfit(realDistances(:), meanMeasured, 1);
fprintf('Kalibrierung: gemessen = %.4f * real + %.3f cm\n', p(1), p(2));
fprintf('  a = 1 waere ideal (Steigung), b = 0 waere ideal (kein Offset)\n');

%% Kennlinie plotten: gemessen vs. real, mit idealer Linie + Fit
figure;
errorbar(realDistances, meanMeasured, stdMeasured, 'o-', 'MarkerFaceColor', 'b');
hold on;
xFit = linspace(min(realDistances), max(realDistances), 100);
plot(xFit, xFit, '--k');               % ideale Linie: gemessen = real
plot(xFit, polyval(p, xFit), '-r');    % gefittete Kalibriergerade
legend('Messwerte (Mittelwert ± std)', 'ideal (gemessen = real)', ...
       'lineare Anpassung', 'Location', 'best');
xlabel('reale Distanz [cm]');
ylabel('gemessener Abstand [cm]');
title('HC-SR04 Kennlinie: gemessene vs. reale Distanz');
grid on;
saveas(gcf, fullfile(resultsDir, 'calibration_curve.png'));

%% Zusatz: Fehler und Streuung getrennt ueber der Distanz betrachten
figure;
subplot(2,1,1);
plot(realDistances, meanMeasured - realDistances(:), 'o-');
yline(0, '--k');
xlabel('reale Distanz [cm]');
ylabel('Fehler (gemessen-real) [cm]');
title('Systematischer Fehler ueber der Distanz');
grid on;

subplot(2,1,2);
plot(realDistances, stdMeasured, 'o-');
xlabel('reale Distanz [cm]');
ylabel('Standardabweichung [cm]');
title('Streuung ueber der Distanz');
grid on;
saveas(gcf, fullfile(resultsDir, 'calibration_error_analysis.png'));
