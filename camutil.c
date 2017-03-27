/*
    camutil, a utility to give relaybot a face (or something)
    Copyright (C) 2015  alicia@ion.nu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <signal.h>
#include <gdk-pixbuf/gdk-pixbuf.h>
#include <libavcodec/avcodec.h>
#include <sys/prctl.h>
#include <libswscale/swscale.h>
#if LIBAVUTIL_VERSION_MAJOR>50 || (LIBAVUTIL_VERSION_MAJOR==50 && LIBAVUTIL_VERSION_MINOR>37)
  #include <libavutil/imgutils.h>
#else
  #include <libavcore/imgutils.h>
#endif

int running=1;

void stoprunning(int x)
{
  running=0;
}

void fullwrite(int fd, void* buf, int len)
{
  while(len>0)
  {
    int wrote=write(fd, buf, len);
    if(wrote<1){return;}
    len-=wrote;
    buf+=wrote;
  }
}

void fixpixels(GdkPixbuf* img)
{
// printf("Channels: %i\n", gdk_pixbuf_get_n_channels(img));
  if(gdk_pixbuf_get_n_channels(img)==4)
  {
    unsigned char* pixels=gdk_pixbuf_get_pixels(img);
    unsigned int i;
    unsigned int pixelcount=gdk_pixbuf_get_width(img)*gdk_pixbuf_get_height(img);
    for(i=0; i<pixelcount; ++i)
    {
      memmove(&pixels[i*3], &pixels[i*4], 3);
    }
  }
}

int main(int argc, char** argv)
{
  signal(SIGUSR1, stoprunning);
  avcodec_register_all();
  AVCodec* vencoder=avcodec_find_encoder(AV_CODEC_ID_FLV1);
  unsigned int delay=500000;
  // Set up camera
  AVCodecContext* ctx=avcodec_alloc_context3(vencoder);
  unsigned int i;
  GdkPixbuf* img;
  GdkPixbufAnimation* anim;
  void** images=0;
  unsigned int imgcount=0;
  for(i=1; i<argc; ++i)
  {
    anim=gdk_pixbuf_animation_new_from_file(argv[i], 0);
    if(!anim){continue;}
    if(gdk_pixbuf_animation_is_static_image(anim)) // Not sure if this is necessary or if it'd just be a single frame anyway
    {
      ++imgcount;
      images=realloc(images, sizeof(void*)*imgcount);
      img=gdk_pixbuf_animation_get_static_image(anim);
      fixpixels(img);
      images[imgcount-1]=gdk_pixbuf_get_pixels(img);
    }else{
      GTimeVal atime={0,0};
      GdkPixbufAnimationIter* iter=gdk_pixbuf_animation_get_iter(anim, &atime);
      GdkPixbuf* firstimg=gdk_pixbuf_animation_iter_get_pixbuf(iter);
      ++imgcount;
      images=realloc(images, sizeof(void*)*imgcount);
      img=gdk_pixbuf_copy(firstimg);
      fixpixels(img);
      images[imgcount-1]=gdk_pixbuf_get_pixels(img);
      while(1)
      {
        if(gdk_pixbuf_animation_iter_advance(iter, &atime))
        {
          img=gdk_pixbuf_animation_iter_get_pixbuf(iter);
          if(img==firstimg){break;}
          img=gdk_pixbuf_copy(img);
          fixpixels(img);
        }
        ++imgcount;
        images=realloc(images, sizeof(void*)*imgcount);
        images[imgcount-1]=gdk_pixbuf_get_pixels(img);
        g_time_val_add(&atime, 100000);
      }
    }
  }
  ctx->width=gdk_pixbuf_get_width(img);
  ctx->height=gdk_pixbuf_get_height(img);
  ctx->pix_fmt=PIX_FMT_YUV420P;
  ctx->time_base.num=1;
  ctx->time_base.den=10;
  avcodec_open2(ctx, vencoder, 0);
  AVFrame* frame=av_frame_alloc();
  frame->format=PIX_FMT_RGB24;
  frame->width=ctx->width;
  frame->height=ctx->height;
  av_image_alloc(frame->data, frame->linesize, ctx->width, ctx->height, frame->format, 1);
  AVPacket packet;
  packet.buf=0;
  packet.data=0;
  packet.size=0;
  packet.dts=AV_NOPTS_VALUE;
  packet.pts=AV_NOPTS_VALUE;

  // Set up frame for conversion from the camera's format to a format the encoder can use
  AVFrame* dstframe=av_frame_alloc();
  dstframe->format=ctx->pix_fmt;
  dstframe->width=ctx->width;
  dstframe->height=ctx->height;
  av_image_alloc(dstframe->data, dstframe->linesize, ctx->width, ctx->height, ctx->pix_fmt, 1);

  struct SwsContext* swsctx=sws_getContext(frame->width, frame->height, PIX_FMT_RGB24, frame->width, frame->height, AV_PIX_FMT_YUV420P, 0, 0, 0, 0);

  i=0;
  while(running)
  {
    usleep(delay);
    if(delay>100000){delay-=50000;}
    ++i;
    if(i>=imgcount){i=0;}
    frame->data[0]=images[i];
    int gotpacket;
    sws_scale(swsctx, (const uint8_t*const*)frame->data, frame->linesize, 0, frame->height, dstframe->data, dstframe->linesize);
    av_init_packet(&packet);
    packet.data=0;
    packet.size=0;
    avcodec_encode_video2(ctx, &packet, dstframe, &gotpacket);
    unsigned char frameinfo=0x22; // Note: differentiating between keyframes and non-keyframes seems to break stuff, so let's just go with all being interframes (1=keyframe, 2=interframe, 3=disposable interframe)
    dprintf(1, "/video %i\n", packet.size+1);
    fullwrite(1, &frameinfo, 1);
    fullwrite(1, packet.data, packet.size);

    av_free_packet(&packet);
  }
  sws_freeContext(swsctx);
  return 1;
}
