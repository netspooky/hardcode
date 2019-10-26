#ifndef _LISTA_HPP_
#define _LISTA_HPP_

class ListanSolmu
{
public:

	//muodostimet ja tuhoajat
	ListanSolmu();
	ListanSolmu(void *ptr);
	~ListanSolmu();

	//asettaa solmun datan halutuksi
	void set(void *ptr);

	//tulostaa tiedot
	void print();

	//osoittimet seuraaviin osiin
	class ListanSolmu *next;
	class ListanSolmu *previous;

	//data, jota solmu kantaa
	void *payload;

};

class Lista
{
public:
	Lista();
	~Lista();
	
	//lisätään listan loppuun alkio (onnistuu aina)
	void add(void *dataptr);
	//poistetaan listan viimeinen alkio (palauttaa false jos lista on tyhjä)
	bool removeLast();
	//lisätään työpointterin jälkeen alkio (palauttaa false jos työpointteri ei ole kelvollinen)
	bool insert(void *dataptr);
	//poistetaan alkio työpointterin kohdalta
	bool remove();

	//tuhotaan koko lista ja vapautetaan kaikki tiedot
	void destroy();

	//asettaa työpointterin listan alkuun (palauttaa false jos lista on tyhjä)
	bool goToStart();
	//asettaa työpointterin listan loppuun (palauttaa false jos lista on tyhjä)
	bool goToEnd();
	//liikuttaa työpointteria eteenpäin (palauttaa false jos lista on loppu)
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
	//kertoo kuinka monta solmua listassa on
	int getNodeCount();
	//kertoo nykyisen noden
	int getCurrentNodeNumber();

	//tulostetaan lista lokiin (debug)
	void print();
private:
	int solmuja;
	ListanSolmu *start;
	ListanSolmu *current;
	ListanSolmu *end;

};

#endif 
