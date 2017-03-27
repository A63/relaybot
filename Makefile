CFLAGS=$(shell pkg-config --cflags gdk-pixbuf-2.0 libavcodec libswscale libavutil)
LIBS=$(shell pkg-config --libs gdk-pixbuf-2.0 libavcodec libswscale libavutil)

camutil: camutil.c
	$(CC) $(CFLAGS) $^ $(LIBS) -o $@
