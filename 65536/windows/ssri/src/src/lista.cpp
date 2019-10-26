#include <stdio.h>
#include "lista.hpp"

//#define LISTDEBUG

ListaKoskaEngineEiToiminSolmu::ListaKoskaEngineEiToiminSolmu()
{
}
ListaKoskaEngineEiToiminSolmu::~ListaKoskaEngineEiToiminSolmu()
{
}
ListaKoskaEngineEiToiminSolmu::ListaKoskaEngineEiToiminSolmu(void *ptr)
{
	payload = ptr;
}
void ListaKoskaEngineEiToiminSolmu::set(void *ptr)
{
	payload = ptr;
}
void ListaKoskaEngineEiToiminSolmu::print()
{

}
ListaKoskaEngineEiToimi::ListaKoskaEngineEiToimi()
{
	//nollataan kaikki osoittimet
	start = 0;
	current = 0;
	end = 0;
	//nollataan solmujen määrä
	solmuja = 0;
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::ListaKoskaEngineEiToimi() : ListaKoskaEngineEiToimi luotu");
#endif
}
ListaKoskaEngineEiToimi::~ListaKoskaEngineEiToimi()
{
}

//lisätään alkio ListaKoskaEngineEiToimin loppuun
void ListaKoskaEngineEiToimi::add(void *dataptr)
{
	ListaKoskaEngineEiToiminSolmu *temp;
	solmuja++;

	if (start == 0) //lisätään ListaKoskaEngineEiToimian ensimmäistä alkiota
	{
		//luodaan uusi solmu
		temp = new ListaKoskaEngineEiToiminSolmu(dataptr);

		//koska solmu on ensimmäinen, nämä ovat molemmat 0
		temp->previous = 0;
		temp->next = 0;

		//molemmat "pääosoittimet" osoittamaan ekaan solmuun
		start = temp;
		end = temp;

#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::add : Luotu ensimmäinen ListaKoskaEngineEiToimin solmu");
		temp->print();
#endif
	}
	else
	{
		//luodaan uusi solmu ListaKoskaEngineEiToimin perälle
		ListaKoskaEngineEiToiminSolmu *temp = new ListaKoskaEngineEiToiminSolmu(dataptr);
		//seuraavaa solmua ei tietenkään ole
		temp->next = 0; 

		//menee yhden askeleen lopun jälkeen. Muutetaan vanha ListaKoskaEngineEiToimin loppu osoittamaan tähän solmuun
		temp->previous = end;
		end->next = temp;

		//uusi solmu on ListaKoskaEngineEiToimin viimeinen
		end = temp;		
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::add : Luotu uusi solmu ListaKoskaEngineEiToimian");
		temp->print();
#endif
	}
}

//laitetaan uusi alkio työosoittimen kohdalle
bool ListaKoskaEngineEiToimi::insert(void *dataptr)
{
	if (current==0)
	{
		return false; //työosoitin ei ole kelvollinen, joten ei tehdä mitään ja palautetaan false
	}
	//ollaan ListaKoskaEngineEiToimin lopussa
	if (current == end)
	{
		add(dataptr); //laitetaan ListaKoskaEngineEiToimin loppuun uusi alkio
		return true;
	}
	//lisääminen onnistuu joka tapauksessa tästä eteenpäin, joten lisätään solmujen määrää
	solmuja++;
	//ollaan ListaKoskaEngineEiToimin alussa tai keskellä, joten luodaan uusi solmu
	ListaKoskaEngineEiToiminSolmu *temp = new ListaKoskaEngineEiToiminSolmu(dataptr); 
	//asetetaan uusi solmu osoittamaan seuraavaan solmuun
	temp->next = current->next;
	//seuraavan solmun previous osoittaa uuteen solmuun
	current->next->previous = temp; 
	//seuraava solmu hoideltu
	//uusi solmu tulee väliin, joten sen edellinen on nykyinen
	temp->previous = current;
	//lopulta säädetään currentin seuraavan osoitin uuteen
	current->next = temp; 

	//huh
	return true;
}


//poistetaan alkio työpointterin kohdalla
bool ListaKoskaEngineEiToimi::remove()
{
	if (start == 0)	//ListaKoskaEngineEiToimi tyhjä
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::remove : ei ole mitään poistettavaa");
#endif
		return false; //ei ole mitään poistettavaa
	}
	if (start == end)		//vain yksi alkio ListaKoskaEngineEiToimissa (current == start)
	{
		solmuja--;
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::remove : vain yksi alkio ListaKoskaEngineEiToimissa");
#endif
		if (current->payload != 0)	//poistetaan lasti jos sitä on
		{
			delete current->payload;
		}
		delete current; //tuhotaan solmu

		start = 0;
		end = 0;
		current = 0; //nollataan pointterit

		return true;
	}
	if (current == end)	//yritetään poistaa viimeistä alkiota
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::remove : poistetaan viimeinen alkio");
#endif
		removeLast();	//solmujen määrä muutetaan täällä
		return false;
	}
	if (current == start) //yritetään poistaa ensimmäistä alkiota
	{
		solmuja--;
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::remove : poistetaan ensimmäistä alkiota");
#endif
		ListaKoskaEngineEiToiminSolmu *temp = start->next;	//osoitetaan ListaKoskaEngineEiToimin toiseen alkioon
		temp->previous = 0;					//josta tehdään ListaKoskaEngineEiToimin ensimmäinen alkio
		if (start->payload != 0)
		{
			delete start->payload;
		}
		delete start; //poistetaan start-osoittimen osoittama alkio
		start = temp; //ja laitetaan se osoittamaan ListaKoskaEngineEiToimin toiseen alkioon, joka on nyt ensimmäinen
		current = temp; //current myös

		return true;
	}
	//erikoistapaukset käsitelty

	solmuja--;
	ListaKoskaEngineEiToiminSolmu *temp;
	if (current->next != 0)
		temp = current->next;
	else
		temp = current->previous;

	current->previous->next = current->next; //hypätään currentin ylitse
	current->next->previous = current->previous;

	if (current->payload != 0)
	{
		delete current->payload;
	}
	delete current;
	current = temp; //current on joko seuraava tai edellinen (jos seuraavaa ei ollut)
	return true;
}

//poistetaan ListaKoskaEngineEiToimin viimeinen alkio

bool ListaKoskaEngineEiToimi::removeLast()
{
	if (start == 0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::removeLast : ei ole mitään poistettavaa");
#endif
		return false; //ei ole mitään poistettavaa
	}
	else
	{
		solmuja--;
		if (end->previous == 0) //jos ListaKoskaEngineEiToimissa on vain yksi alkio
		{
#ifdef LISTDEBUG
			loki->writeToLog("ListaKoskaEngineEiToimi::removeLast : vain yksi alkio");
#endif
			if (end->payload != 0) //jos ListaKoskaEngineEiToimi osoittaa johonkin
			{
				delete end->payload;
			}
			delete end;	//poistetaan viimeinen alkio
			end = 0;	//nollataan nämä, muuten ne osoittavat jonnekin jota ei ole enää olemassa
			start = 0;
			current = 0;
		}
		else		//poistetaan viimeinen alkio
		{
#ifdef LISTDEBUG
			loki->writeToLog("ListaKoskaEngineEiToimi::removeLast");
#endif
			//solmu, joka osoittaa edelliseen
			ListaKoskaEngineEiToiminSolmu *temp = end->previous;

			//tuhotaan viimeisen solmun lasti
			if (end->payload != 0)
			{
				delete end->payload;
			}
			//jos current osoittaa loppuun, vaihdetaan se osoittamaan uuteen loppuun (muuten ryskis)
			if (current == end)
			{
				current = current->previous;
			}
			delete end;
			end = temp;
			temp->next = 0;
		}
		return true; //poisto onnistui
	}
}

//tuhotaan koko ListaKoskaEngineEiToimi
void ListaKoskaEngineEiToimi::destroy()
{
	int temp = solmuja; //solmuja muuttuu removeLastissa, joten siksi tehdään siitä kopio nyt
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::destroy");
#endif
	for (int i=0;i<temp;i++)
		removeLast();
}

bool ListaKoskaEngineEiToimi::goToStart()
{
	if (start!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::goToStart() onnistui");
#endif
		current = start;	//ListaKoskaEngineEiToimi on olemassa
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::goToStart() epäonnistui");
#endif
	current = 0;
	return false;
}
bool ListaKoskaEngineEiToimi::goToEnd()
{
	if (end!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::goToEnd() onnistui");
#endif
		current = end;	//ListaKoskaEngineEiToimi on olemassa
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::goToStart() epäonnistui");
#endif
	current = 0;
	return false;
}
bool ListaKoskaEngineEiToimi::goForward()
{
	if (current == end)
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::goForward() yritti mennä lopusta ylitse!");
#endif
		return false;
	}
	if (current->next!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::goForward() onnistui");
#endif
		current = current->next;
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::goForward() epäonnistui");
#endif
	return false;
}
bool ListaKoskaEngineEiToimi::goBackwards()
{
	if (current->previous!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("ListaKoskaEngineEiToimi::goBackwards() onnistui");
#endif
		current = current->previous;
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::goBackwards() epäonnistui");
#endif
	return false;
}

bool ListaKoskaEngineEiToimi::goToNode(int number)
{
	/* paskaa koodia! */
	bool value;
	goToStart();

	for (int i=0;i<number;i++)
	{
		value = goForward();
	}
	return value;
}
int ListaKoskaEngineEiToimi::getCurrentNodeNumber()
{
	/* paskaa koodia! */
	int i=0;
	ListaKoskaEngineEiToiminSolmu *walker = start;
	while (walker != current)
	{
		i++;
		walker = walker->next;
	}
	return i;

}


void *ListaKoskaEngineEiToimi::getFirst()
{
	return start->payload;
}
void *ListaKoskaEngineEiToimi::getLast()
{
	return end->payload;
}
void *ListaKoskaEngineEiToimi::getCurrent()
{
	return current->payload;
}
void ListaKoskaEngineEiToimi::setCurrent(void *ptr)
{
	if (current->payload) //tuhotaan vanha
	{
		delete current->payload;
	}
	current->payload = ptr; 
}
int ListaKoskaEngineEiToimi::getNodeCount()
{
	return solmuja;
}

bool ListaKoskaEngineEiToimi::isAtEnd()
{
	if (current == end)
		return true;
	else return false;
}

bool ListaKoskaEngineEiToimi::isAtStart()
{
	if (current == start)
		return true;
	else return false;
}

void ListaKoskaEngineEiToimi::print()
{
#ifdef LISTDEBUG
	loki->writeToLog("ListaKoskaEngineEiToimi::print");
#endif
	ListaKoskaEngineEiToiminSolmu *walker = start;
	if (walker == 0)
		return; //ListaKoskaEngineEiToimissa ei ole mitään
	while (walker!=0)
	{
		walker->print();
		walker = walker->next;
	}
}
