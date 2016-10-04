/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.

  Most Arduinos have an on-board LED you can control. On the UNO, MEGA and ZERO 
  it is attached to digital pin 13, on MKR1000 on pin 6. LED_BUILTIN takes care 
  of use the correct LED pin whatever is the board used.
  If you want to know what pin the on-board LED is connected to on your Arduino model, check
  the Technical Specs of your board  at https://www.arduino.cc/en/Main/Products
  
  This example code is in the public domain.

  modified 8 May 2014
  by Scott Fitzgerald
  
  modified 2 Sep 2016
  by Arturo Guadalupi
*/

#include <CurieBLE.h>

BLEPeripheral blePeripheral;  // BLE Peripheral Device (the board you're programming)
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214"); // BLE LED Service

// BLE LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEUnsignedCharCharacteristic switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);

const int ledPin = 13; // pin to use for the LED

int SEL0 = 8;
int SEL1 = 9;
int SEL2 = 10;

int OUT1 = 2;
int OUT2 = 3;
int OUT3 = 4;
int OUT4 = 5;


// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SEL0, OUTPUT);
  pinMode(SEL1, OUTPUT);
  pinMode(SEL2, OUTPUT);

  pinMode(OUT1, OUTPUT);
  pinMode(OUT2, OUTPUT);

  Serial.begin(9600);

  // set advertised local name and service UUID:
  blePeripheral.setLocalName("LED");
  blePeripheral.setAdvertisedServiceUuid(ledService.uuid());

  // add service and characteristic:
  blePeripheral.addAttribute(ledService);
  blePeripheral.addAttribute(switchCharacteristic);

  // set the initial value for the characeristic:
  switchCharacteristic.setValue(0);

  // begin advertising BLE service:
  blePeripheral.begin();

  Serial.println("BLE LED Peripheral");

  // listen for BLE peripherals to connect:
  BLECentral central = blePeripheral.central();

  // if a central is connected to peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());
  }
}

void loop() {
  // listen for BLE peripherals to connect:
  BLECentral central = blePeripheral.central();
  
  // while the central is still connected to peripheral:
  if (central.connected()) {
      // if the remote device wrote to the characteristic,
      // use the value to control the LED:
    if (switchCharacteristic.written()) {
      Serial.println((char)switchCharacteristic.value());
      if (switchCharacteristic.value() > 100) {   // any value other than 0
        digitalWrite(ledPin, HIGH);         // will turn the LED on
      } else {                              // a 0 value
        digitalWrite(ledPin, LOW);          // will turn the LED off
      }
    }
  }
}

void blink(int bank, int* sel) {
  // write select
  digitalWrite(SEL2, sel[2]);
  digitalWrite(SEL1, sel[1]);
  digitalWrite(SEL0, sel[0]);

  // write bank
  digitalWrite(bank, HIGH);
  delay(1000);

  // turn off
  digitalWrite(bank, LOW);
  delay(1000);
}

int bankForChar(uint8_t c) {
  int bank;
  if (c >= 97 && c <= 104) {
    bank = OUT1;
  } else if (c >= 105 && c <= 112) {
    bank = OUT2;
  } else if (c >= 113 && c <= 120) {
    bank = OUT3;
  } else {
    bank = OUT4;
  }

  return bank;
}

void selectForChar(int *sel, uint8_t c) {
  switch (c) {
    case 97:
    case 105:
    case 113:
    case 121:
    sel[0] = 0;
    sel[1] = 0;
    sel[2] = 0;
    break;
    case 98:
    case 106:
    case 114:
    case 122:
    sel[0] = 1;
    sel[1] = 0;
    sel[2] = 0;
    break;
    case 99:
    case 107:
    case 115:
    sel[0] = 0;
    sel[1] = 1;
    sel[2] = 0;
    break;
    case 100:
    case 108:
    case 116:
    sel[0] = 1;
    sel[1] = 1;
    sel[2] = 0;
    break;
    case 101:
    case 109:
    case 117:
    sel[0] = 0;
    sel[1] = 0;
    sel[2] = 1;
    break;
    case 102:
    case 110:
    case 118:
    sel[0] = 1;
    sel[1] = 0;
    sel[2] = 1;
    break;
    case 103:
    case 111:
    case 119:
    sel[0] = 0;
    sel[1] = 1;
    sel[2] = 1;
    break;
    case 104:
    case 112:
    case 120:
    sel[0] = 1;
    sel[1] = 1;
    sel[2] = 1;
    break;
  }
}
