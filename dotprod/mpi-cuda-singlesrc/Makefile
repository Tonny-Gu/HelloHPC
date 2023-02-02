CXX =
CXXFLAGS =
LDFLAGS =

TARGET = dotprod.exe
HEADERS = $(wildcard *.h) # = <empty>
SRCS = $(wildcard *.cu)   # = main.cu
OBJS = $(SRCS:.cu=.o)     # = main.o

all: $(TARGET)

%.o: %.cu $(HEADERS)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

$(TARGET): $(OBJS)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LDFLAGS)

clean:
	@rm -f $(OBJS) $(TARGET)