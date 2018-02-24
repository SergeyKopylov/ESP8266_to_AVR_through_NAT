
// Emulate Serial1 on pins 7/8 if not present
#ifndef HAVE_HWSERIAL1
#include "SoftwareSerial.h"
SoftwareSerial Serial1(7, 8); // RX, TX
#endif

unsigned long prev_millis, cur_millis;

void setup() {
  Serial.begin(115200);   // initialize serial for debugging
  Serial1.begin(115200);   // initialize serial for debugging
}

void loop() {
  // Считываем текущее время:
  cur_millis = millis();

  // *************** Передача данных на сервер *****************
  if ((cur_millis - prev_millis) >= 10000) {
        Serial1.print("=http.get(\"http://192.168.1.2/objects/?script=espdata&dsw1=");
        Serial1.print(random(0,51));
        Serial1.print("&dsw2=");
        Serial1.print(random(0,101));
        Serial1.print("&uptime=");
        Serial1.print(cur_millis/1000);
        Serial1.println("\", \"Authorization: Basic YWRtaW46cGFzc3dvcmQ=\\r\\nAccept: */*\\r\\n\\r\\n\", back)");
        prev_millis = cur_millis;
    }
}
