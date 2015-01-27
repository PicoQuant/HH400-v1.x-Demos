/************************************************************************

  Demo access to HydraHarp 400 Hardware via HHLIB.DLL v 1.2.
  The program performs a TTTR measurement based on hardcoded settings.
  The resulting event data is stored in a binary output file.

  Michael Wahl, PicoQuant GmbH, August 2009

  Note: This is a console application (i.e. run in Windows cmd box)

  Note: At the API level channel numbers are indexed 0..N-1 
		where N is the number of channels the device has.

  Note: This demo writes only raw event data to the output file.
		It does not write a file header as regular .ht* files have it. 


  Tested with the following compilers:

  - MinGW 2.0.0-3 (free compiler for Win 32 bit)
  - MS Visual C++ 6.0 (Win 32 bit)
  - Borland C++ 5.3 (Win 32 bit)

************************************************************************/

#include <windows.h>
#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>

#include "hhdefin.h"
#include "hhlib.h"
#include "errorcodes.h"


unsigned int buffer[TTREADMAX]; 


int main(int argc, char* argv[])
{

 int dev[MAXDEVNUM]; 
 int found=0;
 FILE *fpout;   
 int retcode;
 int ctcstatus;
 char LIB_Version[8];
 char HW_Model[16];
 char HW_Partno[8];
 char HW_Serial[8];
 char Errorstring[40];
 int NumChannels;
 int Mode=MODE_T2; //set T2 or T3 here, observe suitable Syncdivider and Range!
 int Binning=0; //you can change this, meaningful only in T3 mode
 int Offset=0;  //you can change this, meaningful only in T3 mode
 int Tacq=10000; //Measurement time in millisec, you can change this
 int SyncDivider = 1; //you can change this, observe Mode! READ MANUAL!
 int SyncCFDZeroCross=10; //you can change this
 int SyncCFDLevel=50; //you can change this
 int InputCFDZeroCross=10; //you can change this
 int InputCFDLevel=50; //you can change this
 double Resolution; 
 int Syncrate;
 int Countrate;
 int i;
 int flags;
 int nRecords;
 unsigned int Progress;
 int warnings;
 char warningstext[16384]; //must have 16384 bytes of buffer


 printf("\nHydraHarp 400 HHLib.DLL Demo Application    M. Wahl, PicoQuant GmbH, 2009");
 printf("\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
 HH_GetLibraryVersion(LIB_Version);
 printf("\nLibrary version is %s",LIB_Version);
 if(strncmp(LIB_Version,LIB_VERSION,sizeof(LIB_VERSION))!=0)
         printf("\nWarning: The application was built for version %s.",LIB_VERSION);

 if((fpout=fopen("tttrmode.out","wb"))==NULL)
 {
        printf("\ncannot open output file\n"); 
        goto ex;
 }

 printf("\n\n");

 printf("Mode              : %ld\n",Mode);
 printf("Binning           : %ld\n",Binning);
 printf("Offset            : %ld\n",Offset);
 printf("AcquisitionTime   : %ld\n",Tacq);
 printf("SyncDivider       : %ld\n",SyncDivider);
 printf("SyncCFDZeroCross  : %ld\n",SyncCFDZeroCross);
 printf("SyncCFDLevel      : %ld\n",SyncCFDLevel);
 printf("InputCFDZeroCross : %ld\n",InputCFDZeroCross);
 printf("InputCFDLevel     : %ld\n",InputCFDLevel);


 printf("\nSearching for HydraHarp devices...");
 printf("\nDevidx     Status");


 for(i=0;i<MAXDEVNUM;i++)
 {
	retcode = HH_OpenDevice(i, HW_Serial); 
	if(retcode==0) //Grab any HydraHarp we can open
	{
		printf("\n  %1d        S/N %s", i, HW_Serial);
		dev[found]=i; //keep index to devices we want to use
		found++;
	}
	else
	{
		if(retcode==HH_ERROR_DEVICE_OPEN_FAIL)
			printf("\n  %1d        no device", i);
		else 
		{
			HH_GetErrorString(Errorstring, retcode);
			printf("\n  %1d        %s", i,Errorstring);
		}
	}
 }

 //In this demo we will use the first HydraHarp device we find, i.e. dev[0].
 //You can also use multiple devices in parallel.
 //You can also check for specific serial numbers, so that you always know 
 //which physical device you are talking to.

 if(found<1)
 {
	printf("\nNo device available.");
	goto ex; 
 }
 printf("\nUsing device #%1d",dev[0]);
 printf("\nInitializing the device...");

 retcode = HH_Initialize(dev[0],Mode,0);  //with internal clock
 if(retcode<0)
 {
        printf("\nHH_Initialize error %d. Aborted.\n",retcode);
        goto ex;
 }
 
 retcode = HH_GetHardwareInfo(dev[0],HW_Model,HW_Partno); //this is only for information
 if(retcode<0)
 {
        printf("\nHH_GetHardwareInfo error %d. Aborted.\n",retcode);
        goto ex;
 }
 else
	printf("\nFound Model %s Part no %s",HW_Model,HW_Partno);


 retcode = HH_GetNumOfInputChannels(dev[0],&NumChannels); 
 if(retcode<0)
 {
        printf("\nHH_GetNumOfInputChannels error %d. Aborted.\n",retcode);
        goto ex;
 }
 else
	printf("\nDevice has %i input channels.",NumChannels);



 printf("\nCalibrating...");
 retcode=HH_Calibrate(dev[0]);
 if(retcode<0)
 {
        printf("\nCalibration Error %d. Aborted.\n",retcode);
        goto ex;
 }

 retcode = HH_SetSyncDiv(dev[0],SyncDivider); 
 if(retcode<0)
 {
        printf("\nPH_SetSyncDiv error %ld. Aborted.\n",retcode);
        goto ex;
 }

 retcode=HH_SetSyncCFDLevel(dev[0],SyncCFDLevel);
 if(retcode<0)
 {
        printf("\nHH_SetSyncCFDLevel error %ld. Aborted.\n",retcode);
        goto ex;
 }

 retcode = HH_SetSyncCFDZeroCross(dev[0],SyncCFDZeroCross);
 if(retcode<0)
 {
        printf("\nHH_SetSyncCFDZeroCross error %ld. Aborted.\n",retcode);
        goto ex;
 }

 retcode = HH_SetSyncChannelOffset(dev[0],0);
 if(retcode<0)
 {
        printf("\nHH_SetSyncChannelOffset error %ld. Aborted.\n",retcode);
        goto ex;
 }

 for(i=0;i<NumChannels;i++) // we use the same input settings for all channels
 {
	 retcode=HH_SetInputCFDLevel(dev[0],i,InputCFDLevel);
	 if(retcode<0)
	 {
			printf("\nHH_SetInputCFDLevel error %ld. Aborted.\n",retcode);
			goto ex;
	 }

	 retcode = HH_SetInputCFDZeroCross(dev[0],i,InputCFDZeroCross);
	 if(retcode<0)
	 {
			printf("\nHH_SetInputCFDZeroCross error %ld. Aborted.\n",retcode);
			goto ex;
	 }

	 retcode = HH_SetInputChannelOffset(dev[0],i,0);
	 if(retcode<0)
	 {
			printf("\nHH_SetInputChannelOffset error %ld. Aborted.\n",retcode);
			goto ex;
	 }
 }

 if(Mode==MODE_T3)
 {
	 retcode = HH_SetBinning(dev[0],Binning); //Meaningful only in T3 mode
	 if(retcode<0)
	 {
			printf("\nHH_SetBinning error %d. Aborted.\n",retcode);
			goto ex;
	 }

	 retcode = HH_SetOffset(dev[0],Offset); //Meaningful only in T3 mode
	 if(retcode<0)
	 {
			printf("\nHH_SetOffset error %d. Aborted.\n",retcode);
			goto ex;
	 }
 
	 retcode = HH_GetResolution(dev[0], &Resolution); //Meaningful only in T3 mode
	 if(retcode<0)
	 {
			printf("\nHH_GetResolution error %d. Aborted.\n",retcode);
			goto ex;
	 }

	 printf("\nResolution is %1.1lfps", Resolution);
 }

 //Note: after Init or SetSyncDiv you must allow >400 ms for valid  count rate readings
 //Otherwise you get new values after every 100ms
 Sleep(400);

 retcode = HH_GetSyncRate(dev[0], &Syncrate);
 if(retcode<0)
 {
        printf("\nHH_GetSyncRate error %ld. Aborted.\n",retcode);
        goto ex;
 }
 printf("\nSyncrate=%1d/s", Syncrate);

 for(i=0;i<NumChannels;i++) // for all channels
 {
	 retcode = HH_GetCountRate(dev[0],i,&Countrate);
	 if(retcode<0)
	 {
			printf("\nHH_GetCountRate error %ld. Aborted.\n",retcode);
			goto ex;
	 }
	printf("\nCountrate[%1d]=%1d/s", i, Countrate);
 }

 printf("\n");

 //new from v1.2: after getting the count rates you can check for warnings
 retcode = HH_GetWarnings(dev[0],&warnings);
 if(retcode<0)
 {
	printf("\nHH_GetWarnings error %ld. Aborted.\n",retcode);
	goto ex;
 }
 if(warnings)
 {
	 HH_GetWarningsText(dev[0],warningstext, warnings);
	 printf("\n\n%s",warningstext);
 }


 Progress = 0;
 printf("\nProgress:%9u",Progress);

 retcode = HH_StartMeas(dev[0],Tacq); 
 if(retcode<0)
 {
         printf("\nHH_StartMeas error %ld. Aborted.\n",retcode);
         goto ex;
 }

 while(1)
 { 
        retcode = HH_GetFlags(dev[0], &flags);
        if(retcode<0)
        {
                printf("\nHH_GetFlags error %1d. Aborted.\n",flags);
                goto ex;
        }
        
		if (flags&FLAG_FIFOFULL) 
		{
			printf("\nFiFo Overrun!\n"); 
			goto stoptttr;
		}
		
		retcode = HH_ReadFiFo(dev[0],buffer,TTREADMAX,&nRecords);	//may return less!  
		if(retcode<0) 
		{ 
			printf("\nHH_ReadFiFo error %d. Aborted.\n",retcode); 
			goto stoptttr; 
		}  

		if(nRecords) 
		{
			if(fwrite(buffer,4,nRecords,fpout)!=(unsigned)nRecords)
			{
				printf("\nfile write error\n");
				goto stoptttr;
			}               
				Progress += nRecords;
				printf("\b\b\b\b\b\b\b\b\b%9u",Progress);
		}
		else
		{
			retcode = HH_CTCStatus(dev[0], &ctcstatus);
			if(retcode<0)
			{
                printf("\nHH_StartMeas error %ld. Aborted.\n",retcode);
                goto ex;
			}
			if (ctcstatus) 
			{ 
				printf("\nDone\n"); 
				goto stoptttr; 
			}  
		}

		//within this loop you can also read the count rates if needed.
 }
  
stoptttr:

 retcode = HH_StopMeas(dev[0]);
 if(retcode<0)
 {
      printf("\nHH_StopMeas error %1d. Aborted.\n",retcode);
      goto ex;
 }         
  
ex:

 for(i=0;i<MAXDEVNUM;i++) //no harm to close all
 {
	HH_CloseDevice(i);
 }
 if(fpout) fclose(fpout);
 printf("\npress RETURN to exit");
 getchar();

 return 0;
}


