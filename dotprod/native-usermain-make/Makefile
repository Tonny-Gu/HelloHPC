CC =
CFLAGS =
LDFLAGS =

TARGET = dotprod.exe
HEADERS = $(wildcard *.h) # = <empty>
SRCS = $(wildcard *.c) 	  # = main.c
OBJS = $(SRCS:.c=.o)      # = main.o

all: $(TARGET)

%.o: %.c $(HEADERS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean:
	@rm -f $(OBJS) $(TARGET)