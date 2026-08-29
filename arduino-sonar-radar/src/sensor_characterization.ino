/*
 * Sensor-Charakterisierung - HC-SR04
 * ------------------------------------
 * Servo bleibt auf einem festen Winkel stehen (auf ein Objekt in
 * bekannter Distanz ausgerichtet). Es werden N Wiederholungsmessungen
 * genommen und ueber Serial als CSV ausgegeben (index,abstand_cm).
 * Ziel: Praezision/Streuung des Sensors bei konstanter Distanz
 * beurteilen (Mittelwert, Standardabweichung, Min/Max) - Basis fuer
 * die MATLAB-Auswertung.
 *
 * Objekt VOR dem Start in bekannter, fester Distanz vor den Sensor
 * stellen (z.B. mit Lineal/Zollstock nachmessen) und diese reale
 * Distanz notieren - sie wird spaeter fuer den Exaktheitsvergleich
 * gebraucht.
 */

#include <Servo.h>

Servo myservo;

const int trigPin = 10;
const int echoPin = 13;
const int servoPin = 3;

const int servoAngle = 90;      // fester Winkel, auf das Objekt ausgerichtet
const int numSamples = 100;     // Anzahl Wiederholungsmessungen
const int sampleDelayMs = 200;  // Pause zwischen den Messungen

void setup() {
  Serial.begin(9600);
  myservo.attach(servoPin);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  myservo.write(servoAngle);
  delay(500); // Servo Zeit geben, die Position zu erreichen

  Serial.println("index,abstand_cm");

  for (int i = 0; i < numSamples; i++) {
    float distance = measureDistanceCm();
    Serial.print(i);
    Serial.print(",");
    Serial.println(distance);
    delay(sampleDelayMs);
  }

  Serial.println("# Messung abgeschlossen");
}

void loop() {
  // absichtlich leer: einmalige Messreihe laeuft in setup()
}

float measureDistanceCm() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH);
  return duration * 0.017;
}
