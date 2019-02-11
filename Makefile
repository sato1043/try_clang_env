
TARGET := a.out

MAIN_C := ./main.c
TEST_C := ./test.c
SRCS := $(filter-out $(TEST_C), $(wildcard ./*.c) $(wildcard ./**/*.c))
OBJS := $(SRCS:%.c=%.o)
DEPS := $(SRCS:%.c=%.d)
-include $(DEPS)

TSRCS := $(filter-out $(MAIN_C), $(wildcard ./*.c) $(wildcard ./**/*.c))
TOBJS := $(TSRCS:%.c=%.o)
TDEPS := $(TSRCS:%.c=%.d)
-include $(TDEPS)

.PHONY: release debug all check clean test

CFLAGS := -std=c17 -Wall -Wextra -pedantic -Wstrict-overflow -fno-strict-aliasing -Wno-missing-field-initializers
CFLAGS_D :=-O0 -DDEBUG -g -Werror -Wshadow
CFLAGS_R :=-O2 -DNDEBUG

LDFLAGS :=
LDFLAGS_D :=-g -debug
LDFLAGS_R :=

all: CFLAGS+=$(CFLAGS_R)
all: LDFLAGS+=$(LDFLAGS_R)
all: clean $(TARGET)

debug: CFLAGS+=$(CFLAGS_D)
debug: LDFLAGS+=$(LDFLAGS_D)
debug: check $(TARGET)

CC := clang

.c.o:
	$(CC) -MMD -MP $(CFLAGS) -c $<

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

run: $(TARGET)
	valgrind --leak-check=full --show-leak-kinds=all ./$(TARGET)

test: $(TARGET).cunit
	valgrind --leak-check=full --show-leak-kinds=all ./$(TARGET).cunit

$(TARGET).cunit: $(TOBJS)
	$(CC) $(LDFLAGS) -lcunit -o $(TARGET).cunit $(TOBJS)

dSYM: $(TARGET)
	dsymutil $(TARGET)

check:
	@for src in $(SRCS) ; do \
		clang-format -i "$$src" ; \
		cppcheck --enable=all --check-config "$$src" ; \
		clang-tidy "$$src" -checks=-*,clang-analyzer-*,-clang-analyzer-cplusplus* ; ¥
	done

clean:
	-rm -rf $(DEPS) $(OBJS) $(TDEPS) $(TOBJS) $(TARGET) $(TARGET).dSYM $(TARGET).cunit $(TARGET).cunit.dSYM
