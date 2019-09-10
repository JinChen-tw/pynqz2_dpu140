PROJECT   =   yolo

CXX       :=   g++
CC        :=   gcc
OBJ       :=   main.o

# linking libraries of OpenCV
LDFLAGS   =   $(shell pkg-config --libs opencv)
# linking libraries of DNNDK 
LDFLAGS   +=  -lhineon -ln2cube -ldputils -lpthread

CUR_DIR =   $(shell pwd)
SRC     =   $(CUR_DIR)/src
BUILD   =   $(CUR_DIR)/build
MODEL   =   $(CUR_DIR)/model
#MODEL   =   $(CUR_DIR)/output_baseline
#MODEL   =   $(CUR_DIR)/output_pruned
VPATH   =   $(SRC)
ARCH	= 	$(shell uname -m | sed -e s/arm.*/armv71/ \
				  -e s/aarch64.*/aarch64/ )

CFLAGS    :=   -O3 -Wall -Wpointer-arith -std=c++11 -ffast-math
ifeq ($(ARCH),armv71)
    #CFLAGS +=  -mcpu=cortex-a9 -mfloat-abi=hard -mfpu=neon
    CFLAGS +=  -mcpu=cortex-a9 -mfpu=neon
    MODEL = $(CUR_DIR)/model/dpu_yolo.elf
endif 
ifeq ($(ARCH),aarch64)
    CFLAGS += -mcpu=cortex-a53
    MODEL = $(CUR_DIR)/model/dpu_yolo.elf 
endif
 
.PHONY: all clean 

all: $(BUILD) $(PROJECT) 
 
$(PROJECT) : $(OBJ) 
	$(CXX) $(CFLAGS) $(addprefix $(BUILD)/, $^) $(MODEL) -o $@ $(LDFLAGS)
 
%.o : %.cpp
	$(CXX) -c $(CFLAGS) $< -o $(BUILD)/$@
 
clean:
	$(RM) -rf $(BUILD)
	$(RM) $(PROJECT) 

$(BUILD) : 
	-mkdir -p $@ 
