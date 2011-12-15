#include "html.h"

static inline int increment(int i) {
  if (i == BUF_SIZE - 1)
    return i;
  return i + 1;
}

void parseHTML(Client *client, onTagFunc onTag) {
  static char buf[BUF_SIZE];
  int i = 0;
  int insideTag = 0;
  while(client->connected()) {
    if (client->available()) {
      char c = client->read();
      if (insideTag) {
	if (c == '>') {
	  buf[i] = '\0';
	  if (onTag(client, buf)) {
	    client->flush();
	    return;
	  }
	  i = 0;
	  insideTag = 0;
	} else {
  	  buf[i] = c;
	  i = increment(i);
	}
      } else if (c == '<') {
        insideTag = 1;
      }
    }
  }
}
