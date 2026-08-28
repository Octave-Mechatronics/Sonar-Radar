/*
 * Sonar Radar - Ultraschallbasierte Abstandsmessung mit Arduino
 * ---------------------------------------------------------------
 * HC-SR04 Ultraschallsensor auf einem Servo montiert (0-180 Grad
 * Schwenkbereich). Fuer jeden Winkelschritt wird der Abstand
 * gemessen; RGB-LED und Buzzer zeigen die Distanz optisch und
 * akustisch an. Ueber die serielle Schnittstelle wird jedes
 * Messwertpaar (Winkel, Abstand) ausgegeben, damit die Daten in
 * MATLAB (oder jedem anderen Tool) ausgewertet werden koennen.
 *
 * Author: Octave
 */

#include <Servo.h>

Servo myservo;

const int trigPin = 10;
const int echoPin = 13;
const int servoPin = 3;

const int buzzerPin = 9;
const int redPin = 4;
const int greenPin = 5;
const int bluePin = 6;

// Schwellenwerte fuer die Abstandsanzeige (in cm)
const float DIST_FAR = 40.0;
const float DIST_NEAR = 10.0;

void setup() {
  Serial.begin(9600);

  myservo.attach(servoPin);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  Serial.println("winkel_deg,abstand_cm");
}

void loop() {
  for (int deg = 0; deg <= 180; deg++) {
    scanStep(deg);
  }
  for (int deg = 180; deg >= 0; deg--) {
    scanStep(deg);
  }
}

// Fuehrt einen einzelnen Messschritt aus: Servo positionieren,
// Abstand messen, LED/Buzzer aktualisieren, Messwert per Serial senden.
void scanStep(int deg) {
  myservo.write(deg);
  delay(10);

  float distance = measureDistanceCm();
  updateIndicators(distance);

  Serial.print(deg);
  Serial.print(",");
  Serial.println(distance);
}

// Loest eine HC-SR04 Messung aus und gibt den Abstand in cm zurueck.
float measureDistanceCm() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH);
  return duration * 0.017; // d[cm] = t[us] * Schallgeschwindigkeit / 2, siehe README
}

// Setzt RGB-LED-Farbe und Buzzer-Ton passend zum gemessenen Abstand.
void updateIndicators(float distance) {
  if (distance > DIST_FAR) {
    setColor(false, true, false); // gruen: frei
    noTone(buzzerPin);
  } else if (distance > DIST_NEAR) {
    setColor(true, true, false); // gelb: Warnbereich
    tone(buzzerPin, 100);
  } else {
    setColor(true, false, false); // rot: nah
    tone(buzzerPin, 500);
  }
}

void setColor(bool r, bool g, bool b) {
  digitalWrite(redPin, r ? HIGH : LOW);
  digitalWrite(greenPin, g ? HIGH : LOW);
  digitalWrite(bluePin, b ? HIGH : LOW);
}
