CC =
CFLAGS =
LDFLAGS =

TARGET = libdotprod.so
HEADERS = $(wildcard *.h) # = dotprod.h
SRCS = $(wildcard *.c) 	  # = dotprod.c
OBJS = $(SRCS:.c=.o)      # = dotprod.o

all: $(TARGET)

%.o: %.c $(HEADERS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean:
	@rm -f $(OBJS) $(TARGET)