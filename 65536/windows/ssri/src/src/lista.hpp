#ifndef _ListaKoskaEngineEiToimi_HPP_
#define _ListaKoskaEngineEiToimi_HPP_

class ListaKoskaEngineEiToiminSolmu
{
public:

	//muodostimet ja tuhoajat
	ListaKoskaEngineEiToiminSolmu();
	ListaKoskaEngineEiToiminSolmu(void *ptr);
	~ListaKoskaEngineEiToiminSolmu();

	//asettaa solmun datan halutuksi
	void set(void *ptr);

	//tulostaa tiedot
	void print();

	//osoittimet seuraaviin osiin
	class ListaKoskaEngineEiToiminSolmu *next;
	class ListaKoskaEngineEiToiminSolmu *previous;

	//data, jota solmu kantaa
	void *payload;

};

class ListaKoskaEngineEiToimi
{
public:
	ListaKoskaEngineEiToimi();
	~ListaKoskaEngineEiToimi();
	
	//lisätään ListaKoskaEngineEiToimin loppuun alkio (onnistuu aina)
	void add(void *dataptr);
	//poistetaan ListaKoskaEngineEiToimin viimeinen alkio (palauttaa false jos ListaKoskaEngineEiToimi on tyhjä)
	bool removeLast();
	//lisätään työpointterin jälkeen alkio (palauttaa false jos työpointteri ei ole kelvollinen)
	bool insert(void *dataptr);
	//poistetaan alkio työpointterin kohdalta
	bool remove();

	//tuhotaan koko ListaKoskaEngineEiToimi ja vapautetaan kaikki tiedot
	void destroy();

	//asettaa työpointterin ListaKoskaEngineEiToimin alkuun (palauttaa false jos ListaKoskaEngineEiToimi on tyhjä)
	bool goToStart();
	//asettaa työpointterin ListaKoskaEngineEiToimin loppuun (palauttaa false jos ListaKoskaEngineEiToimi on tyhjä)
	bool goToEnd();
	//liikuttaa työpointteria eteenpäin (palauttaa false jos ListaKoskaEngineEiToimi on loppu)
	bool goForward();
	//liikuttaa työpointteria taaksepäin (palauttaa false jos ollaan alussa)
	bool goBackwards();
	//menee haluttuun nodeen (palauttaa false jos ei onnistu)
	bool goToNode(int number); 

	//tutkii, ollaanko ekassa nodessa
	bool isAtEnd();
	//tutkii, ollaanko vikassa nodessa
	bool isAtStart();

	//antaa ensimmäisen noden osoittaman tiedon
	void *getFirst();
	//antaa viimeisen noden osoittaman tiedon
	void *getLast();
	//antaa työpointterin osoittaman tiedon
	void *getCurrent();
	//asettaa työpointterin nodeen uuden tiedon (tuhoaa vanhan jos siellä sellaista on)
	void setCurrent(void *ptr);
	//kertoo kuinka monta solmua ListaKoskaEngineEiToimissa on
	int getNodeCount();
	//kertoo nykyisen noden
	int getCurrentNodeNumber();

	//tulostetaan ListaKoskaEngineEiToimi lokiin (debug)
	void print();
private:
	int solmuja;
	ListaKoskaEngineEiToiminSolmu *start;
	ListaKoskaEngineEiToiminSolmu *current;
	ListaKoskaEngineEiToiminSolmu *end;

};

#endif
