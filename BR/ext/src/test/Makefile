OBJS := test.o
test: $(OBJS)
	$(CC) -o test $(CFLAGS) $(LDFLAGS) $(OBJS)
$(OBJS) : %.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@
