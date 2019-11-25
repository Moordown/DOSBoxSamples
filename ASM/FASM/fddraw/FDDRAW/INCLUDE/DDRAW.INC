
; DirectDraw interface

virtual at 0
  IDirectDraw:
    .QueryInterface	     dd  ?
    .AddRef		     dd  ?
    .Release		     dd  ?
    .Compact		     dd  ?
    .CreateClipper	     dd  ?
    .CreatePalette	     dd  ?
    .CreateSurface	     dd  ?
    .DuplicateSurface	     dd  ?
    .EnumDisplayModes	     dd  ?
    .EnumSurfaces	     dd  ?
    .FlipToGDISurface	     dd  ?
    .GetCaps		     dd  ?
    .GetDisplayMode	     dd  ?
    .GetFourCCCodes	     dd  ?
    .GetGDISurface	     dd  ?
    .GetMonitorFrequency     dd  ?
    .GetScanLine	     dd  ?
    .GetVerticalBlankStatus  dd  ?
    .Initialize 	     dd  ?
    .RestoreDisplayMode      dd  ?
    .SetCooperativeLevel     dd  ?
    .SetDisplayMode	     dd  ?
    .WaitForVerticalBlank    dd  ?
    ; added in v2 interface:
    .GetAvailableVidMem      dd  ?
    ; added in v4 interface:
    .GetSurfaceFromDC	     dd  ?
    .RestoreAllSurfaces      dd  ?
    .TestCooperativeLevel    dd  ?
    .GetDeviceIdentifier     dd  ?
    .StartModeTest	     dd  ?
    .EvaluateMode	     dd  ?
end virtual

virtual at 0
  IDirectDrawSurface:
    .QueryInterface	     dd  ?
    .AddRef		     dd  ?
    .Release		     dd  ?
    .AddAttachedSurface      dd  ?
    .AddOverlayDirtyRect     dd  ?
    .Blt		     dd  ?
    .BltBatch		     dd  ?
    .BltFast		     dd  ?
    .DeleteAttachedSurface   dd  ?
    .EnumAttachedSurfaces    dd  ?
    .EnumOverlayZOrders      dd  ?
    .Flip		     dd  ?
    .GetAttachedSurface      dd  ?
    .GetBltStatus	     dd  ?
    .GetCaps		     dd  ?
    .GetClipper 	     dd  ?
    .GetColorKey	     dd  ?
    .GetDC		     dd  ?
    .GetFlipStatus	     dd  ?
    .GetOverlayPosition      dd  ?
    .GetPalette 	     dd  ?
    .GetPixelFormat	     dd  ?
    .GetSurfaceDesc	     dd  ?
    .Initialize 	     dd  ?
    .IsLost		     dd  ?
    .LockSurface	     dd  ?
    .ReleaseDC		     dd  ?
    .Restore		     dd  ?
    .SetClipper 	     dd  ?
    .SetColorKey	     dd  ?
    .SetOverlayPosition      dd  ?
    .SetPalette 	     dd  ?
    .UnlockSurface	     dd  ?
    .UpdateOverlay	     dd  ?
    .UpdateOverlayDisplay    dd  ?
    .UpdateOverlayZOrder     dd  ?
    ; added in v2 interface:
    .GetDDInterface	     dd  ?
    .PageLock		     dd  ?
    .PageUnlock 	     dd  ?
    ; added in v3 interface:
    .SetSurfaceDesc	     dd  ?
    ; added in v4 interface:
    .SetPrivateData	     dd  ?
    .GetPrivateData	     dd  ?
    .FreePrivateData	     dd  ?
    .GetUniquenessValue      dd  ?
    .ChangeUniquenessValue   dd  ?
    ; added in v7 interface:
    .SetPriority	     dd  ?
    .GetPriority	     dd  ?
    .SetLOD		     dd  ?
    .GetLOD		     dd  ?
end virtual

virtual at 0
  IDirectDrawPalette:
    .QueryInterface	     dd  ?
    .AddRef		     dd  ?
    .Release		     dd  ?
    .GetCaps		     dd  ?
    .GetEntries 	     dd  ?
    .Initialize 	     dd  ?
    .SetEntries 	     dd  ?
end virtual

virtual at 0
  IDirectDrawClipper:
    .QueryInterface	     dd  ?
    .AddRef		     dd  ?
    .Release		     dd  ?
    .GetClipList	     dd  ?
    .GetHWnd		     dd  ?
    .Initialize 	     dd  ?
    .IsClipListChanged	     dd  ?
    .SetClipList	     dd  ?
    .SetHWnd		     dd  ?
end virtual

virtual at 0
  IDirectDrawColorControl:
    .QueryInterface	     dd  ?
    .AddRef		     dd  ?
    .Release		     dd  ?
    .GetColorControls	     dd  ?
    .SetColorControls	     dd  ?
end virtual

virtual at 0
  IDirectDrawGammaControl:
    .QueryInterface	     dd  ?
    .AddRef		     dd  ?
    .Release		     dd  ?
    .GetGammaRamp	     dd  ?
    .SetGammaRamp	     dd  ?
end virtual

struc DDCOLORKEY
 {
	.dwColorSpaceLowValue	  dd   ?
	.dwColorSpaceHighValue	  dd   ?
 }

struc DDPIXELFORMAT
 {
	.dwSize 	      dd   ?
	.dwFlags	      dd   ?
	.dwFourCC	      dd   ?
  label .dwYUVBitCount	      dword
  label .dwZBufferBitDepth    dword
  label .dwAlphaBitDepth      dword
	.dwRGBBitCount	      dd   ?
  label .dwYBitMask	      dword
	.dwRBitMask	      dd   ?
  label .dwUBitMask	      dword
	.dwGBitMask	      dd   ?
  label .dwVBitMask	      dword
	.dwBBitMask	      dd   ?
  label .dwYUVAlphaBitMask    dword
  label .dwRGBZBitMask	      dword
  label .dwYUVZBitMask	      dword
	.dwRGBAlphaBitMask    dd   ?
 }

struc DDSCAPS
 {
	.dwCaps 	      dd   ?
 }

struc DDSURFACEDESC
 {
	.dwSize 	      dd   ?
	.dwFlags	      dd   ?
	.dwHeight	      dd   ?
	.dwWidth	      dd   ?
  label .dwLinearSize dword
	.lPitch 	      dd   ?
	.dwBackBufferCount    dd   ?
  label .dwZBufferBitDepth dword
  label .dwRefreshRate dword
	.dwMipMapCount	      dd   ?
	.dwAlphaBitDepth      dd   ?
	.dwReserved	      dd   ?
	.lpSurface	      dd   ?
	.ddckCKDestOverlay    DDCOLORKEY
	.ddckCKDestBlt	      DDCOLORKEY
	.ddckCKSrcOverlay     DDCOLORKEY
	.ddckCKSrcBlt	      DDCOLORKEY
	.ddpfPixelFormat      DDPIXELFORMAT
	.ddsCaps	      DDSCAPS
	.end:
 }

; SetCooperativeLevel flags

DDSCL_FULLSCREEN       =     000000001h
DDSCL_ALLOWREBOOT      =     000000002h
DDSCL_NOWINDOWCHANGES  =     000000004h
DDSCL_NORMAL	       =     000000008h
DDSCL_EXCLUSIVE        =     000000010h
DDSCL_ALLOWMODEX       =     000000040h

; Blt flags

DDBLT_ALPHADEST 		 =     000000001h
DDBLT_ALPHADESTCONSTOVERRIDE	 =     000000002h
DDBLT_ALPHADESTNEG		 =     000000004h
DDBLT_ALPHADESTSURFACEOVERRIDE	 =     000000008h
DDBLT_ALPHAEDGEBLEND		 =     000000010h
DDBLT_ALPHASRC			 =     000000020h
DDBLT_ALPHASRCCONSTOVERRIDE	 =     000000040h
DDBLT_ALPHASRCNEG		 =     000000080h
DDBLT_ALPHASRCSURFACEOVERRIDE	 =     000000100h
DDBLT_ASYNC			 =     000000200h
DDBLT_COLORFILL 		 =     000000400h
DDBLT_DDFX			 =     000000800h
DDBLT_DDROPS			 =     000001000h
DDBLT_KEYDEST			 =     000002000h
DDBLT_KEYDESTOVERRIDE		 =     000004000h
DDBLT_KEYSRC			 =     000008000h
DDBLT_KEYSRCOVERRIDE		 =     000010000h
DDBLT_ROP			 =     000020000h
DDBLT_ROTATIONANGLE		 =     000040000h
DDBLT_ZBUFFER			 =     000080000h
DDBLT_ZBUFFERDESTCONSTOVERRIDE	 =     000100000h
DDBLT_ZBUFFERDESTOVERRIDE	 =     000200000h
DDBLT_ZBUFFERSRCCONSTOVERRIDE	 =     000400000h
DDBLT_ZBUFFERSRCOVERRIDE	 =     000800000h
DDBLT_WAIT			 =     001000000h
DDBLT_DEPTHFILL 		 =     002000000h

; BltFast flags

DDBLTFAST_NOCOLORKEY	 =     000000000h
DDBLTFAST_SRCCOLORKEY	 =     000000001h
DDBLTFAST_DESTCOLORKEY	 =     000000002h
DDBLTFAST_WAIT		 =     000000010h

; Flip flags

DDFLIP_WAIT   =     000000001h
DDFLIP_EVEN   =     000000002h
DDFLIP_ODD    =     000000004h

DDSD_CAPS	      =     000000001h
DDSD_HEIGHT	      =     000000002h
DDSD_WIDTH	      =     000000004h
DDSD_PITCH	      =     000000008h
DDSD_BACKBUFFERCOUNT  =     000000020h
DDSD_ZBUFFERBITDEPTH  =     000000040h
DDSD_ALPHABITDEPTH    =     000000080h
DDSD_LPSURFACE	      =     000000800h
DDSD_PIXELFORMAT      =     000001000h
DDSD_CKDESTOVERLAY    =     000002000h
DDSD_CKDESTBLT	      =     000004000h
DDSD_CKSRCOVERLAY     =     000008000h
DDSD_CKSRCBLT	      =     000010000h
DDSD_MIPMAPCOUNT      =     000020000h
DDSD_REFRESHRATE      =     000040000h
DDSD_LINEARSIZE       =     000080000h
DDSD_ALL	      =     0000FF9EEh

; DirectDrawSurface capability flags

DDSCAPS_RESERVED1	    =	  000000001h
DDSCAPS_ALPHA		    =	  000000002h
DDSCAPS_BACKBUFFER	    =	  000000004h
DDSCAPS_COMPLEX 	    =	  000000008h
DDSCAPS_FLIP		    =	  000000010h
DDSCAPS_FRONTBUFFER	    =	  000000020h
DDSCAPS_OFFSCREENPLAIN	    =	  000000040h
DDSCAPS_OVERLAY 	    =	  000000080h
DDSCAPS_PALETTE 	    =	  000000100h
DDSCAPS_PRIMARYSURFACE	    =	  000000200h
DDSCAPS_PRIMARYSURFACELEFT  =	  000000400h
DDSCAPS_SYSTEMMEMORY	    =	  000000800h
DDSCAPS_TEXTURE 	    =	  000001000h
DDSCAPS_3DDEVICE	    =	  000002000h
DDSCAPS_VIDEOMEMORY	    =	  000004000h
DDSCAPS_VISIBLE 	    =	  000008000h
DDSCAPS_WRITEONLY	    =	  000010000h
DDSCAPS_ZBUFFER 	    =	  000020000h
DDSCAPS_OWNDC		    =	  000040000h
DDSCAPS_LIVEVIDEO	    =	  000080000h
DDSCAPS_HWCODEC 	    =	  000100000h
DDSCAPS_MODEX		    =	  000200000h
DDSCAPS_MIPMAP		    =	  000400000h
DDSCAPS_RESERVED2	    =	  000800000h
DDSCAPS_ALLOCONLOAD	    =	  004000000h
DDSCAPS_VIDEOPORT	    =	  008000000h
DDSCAPS_LOCALVIDMEM	    =	  010000000h
DDSCAPS_NONLOCALVIDMEM	    =	  020000000h
DDSCAPS_STANDARDVGAMODE     =	  040000000h
DDSCAPS_OPTIMIZED	    =	  080000000h

; DirectDrawSurface lock flags

DDLOCK_SURFACEMEMORYPTR   =	000000000h
DDLOCK_WAIT		  =	000000001h
DDLOCK_EVENT		  =	000000002h
DDLOCK_READONLY 	  =	000000010h
DDLOCK_WRITEONLY	  =	000000020h
DDLOCK_NOSYSLOCK	  =	000000800h

; DirectDrawPalette capabilities

DDPCAPS_4BIT		    =	  000000001h
DDPCAPS_8BITENTRIES	    =	  000000002h
DDPCAPS_8BIT		    =	  000000004h
DDPCAPS_INITIALIZE	    =	  000000008h
DDPCAPS_PRIMARYSURFACE	    =	  000000010h
DDPCAPS_PRIMARYSURFACELEFT  =	  000000020h
DDPCAPS_ALLOW256	    =	  000000040h
DDPCAPS_VSYNC		    =	  000000080h
DDPCAPS_1BIT		    =	  000000100h
DDPCAPS_2BIT		    =	  000000200h

; DirectDraw errors

DDERR_ALREADYINITIALIZED	  =	088760000h+5
DDERR_CANNOTATTACHSURFACE	  =	088760000h+10
DDERR_CANNOTDETACHSURFACE	  =	088760000h+20
DDERR_CURRENTLYNOTAVAIL 	  =	088760000h+40
DDERR_EXCEPTION 		  =	088760000h+55
DDERR_HEIGHTALIGN		  =	088760000h+90
DDERR_INCOMPATIBLEPRIMARY	  =	088760000h+95
DDERR_INVALIDCAPS		  =	088760000h+100
DDERR_INVALIDCLIPLIST		  =	088760000h+110
DDERR_INVALIDMODE		  =	088760000h+120
DDERR_INVALIDOBJECT		  =	088760000h+130
DDERR_INVALIDPIXELFORMAT	  =	088760000h+145
DDERR_INVALIDRECT		  =	088760000h+150
DDERR_LOCKEDSURFACES		  =	088760000h+160
DDERR_NO3D			  =	088760000h+170
DDERR_NOALPHAHW 		  =	088760000h+180
DDERR_NOCLIPLIST		  =	088760000h+205
DDERR_NOCOLORCONVHW		  =	088760000h+210
DDERR_NOCOOPERATIVELEVELSET	  =	088760000h+212
DDERR_NOCOLORKEY		  =	088760000h+215
DDERR_NOCOLORKEYHW		  =	088760000h+220
DDERR_NODIRECTDRAWSUPPORT	  =	088760000h+222
DDERR_NOEXCLUSIVEMODE		  =	088760000h+225
DDERR_NOFLIPHW			  =	088760000h+230
DDERR_NOGDI			  =	088760000h+240
DDERR_NOMIRRORHW		  =	088760000h+250
DDERR_NOTFOUND			  =	088760000h+255
DDERR_NOOVERLAYHW		  =	088760000h+260
DDERR_NORASTEROPHW		  =	088760000h+280
DDERR_NOROTATIONHW		  =	088760000h+290
DDERR_NOSTRETCHHW		  =	088760000h+310
DDERR_NOT4BITCOLOR		  =	088760000h+316
DDERR_NOT4BITCOLORINDEX 	  =	088760000h+317
DDERR_NOT8BITCOLOR		  =	088760000h+320
DDERR_NOTEXTUREHW		  =	088760000h+330
DDERR_NOVSYNCHW 		  =	088760000h+335
DDERR_NOZBUFFERHW		  =	088760000h+340
DDERR_NOZOVERLAYHW		  =	088760000h+350
DDERR_OUTOFCAPS 		  =	088760000h+360
DDERR_OUTOFVIDEOMEMORY		  =	088760000h+380
DDERR_OVERLAYCANTCLIP		  =	088760000h+382
DDERR_OVERLAYCOLORKEYONLYONEACTI  =	088760000h+384
DDERR_PALETTEBUSY		  =	088760000h+387
DDERR_COLORKEYNOTSET		  =	088760000h+400
DDERR_SURFACEALREADYATTACHED	  =	088760000h+410
DDERR_SURFACEALREADYDEPENDENT	  =	088760000h+420
DDERR_SURFACEBUSY		  =	088760000h+430
DDERR_CANTLOCKSURFACE		  =	088760000h+435
DDERR_SURFACEISOBSCURED 	  =	088760000h+440
DDERR_SURFACELOST		  =	088760000h+450
DDERR_SURFACENOTATTACHED	  =	088760000h+460
DDERR_TOOBIGHEIGHT		  =	088760000h+470
DDERR_TOOBIGSIZE		  =	088760000h+480
DDERR_TOOBIGWIDTH		  =	088760000h+490
DDERR_UNSUPPORTEDFORMAT 	  =	088760000h+510
DDERR_UNSUPPORTEDMASK		  =	088760000h+520
DDERR_VERTICALBLANKINPROGRESS	  =	088760000h+537
DDERR_WASSTILLDRAWING		  =	088760000h+540
DDERR_XALIGN			  =	088760000h+560
DDERR_INVALIDDIRECTDRAWGUID	  =	088760000h+561
DDERR_DIRECTDRAWALREADYCREATED	  =	088760000h+562
DDERR_NODIRECTDRAWHW		  =	088760000h+563
DDERR_PRIMARYSURFACEALREADYEXIST  =	088760000h+564
DDERR_NOEMULATION		  =	088760000h+565
DDERR_REGIONTOOSMALL		  =	088760000h+566
DDERR_CLIPPERISUSINGHWND	  =	088760000h+567
DDERR_NOCLIPPERATTACHED 	  =	088760000h+568
DDERR_NOHWND			  =	088760000h+569
DDERR_HWNDSUBCLASSED		  =	088760000h+570
DDERR_HWNDALREADYSET		  =	088760000h+571
DDERR_NOPALETTEATTACHED 	  =	088760000h+572
DDERR_NOPALETTEHW		  =	088760000h+573
DDERR_BLTFASTCANTCLIP		  =	088760000h+574
DDERR_NOBLTHW			  =	088760000h+575
DDERR_NODDROPSHW		  =	088760000h+576
DDERR_OVERLAYNOTVISIBLE 	  =	088760000h+577
DDERR_NOOVERLAYDEST		  =	088760000h+578
DDERR_INVALIDPOSITION		  =	088760000h+579
DDERR_NOTAOVERLAYSURFACE	  =	088760000h+580
DDERR_EXCLUSIVEMODEALREADYSET	  =	088760000h+581
DDERR_NOTFLIPPABLE		  =	088760000h+582
DDERR_CANTDUPLICATE		  =	088760000h+583
DDERR_NOTLOCKED 		  =	088760000h+584
DDERR_CANTCREATEDC		  =	088760000h+585
DDERR_NODC			  =	088760000h+586
DDERR_WRONGMODE 		  =	088760000h+587
DDERR_IMPLICITLYCREATED 	  =	088760000h+588
DDERR_NOTPALETTIZED		  =	088760000h+589
DDERR_UNSUPPORTEDMODE		  =	088760000h+590
DDERR_NOMIPMAPHW		  =	088760000h+591
DDERR_INVALIDSURFACETYPE	  =	088760000h+592
DDERR_NOOPTIMIZEHW		  =	088760000h+600
DDERR_NOTLOADED 		  =	088760000h+601
DDERR_DCALREADYCREATED		  =	088760000h+620
DDERR_NONONLOCALVIDMEM		  =	088760000h+630
DDERR_CANTPAGELOCK		  =	088760000h+640
DDERR_CANTPAGEUNLOCK		  =	088760000h+660
DDERR_NOTPAGELOCKED		  =	088760000h+680
DDERR_MOREDATA			  =	088760000h+690
DDERR_VIDEONOTACTIVE		  =	088760000h+695
DDERR_DEVICEDOESNTOWNSURFACE	  =	088760000h+699
