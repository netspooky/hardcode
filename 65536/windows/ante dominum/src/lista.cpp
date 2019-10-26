#include <stdio.h>
#include "lista.hpp"

//#define LISTDEBUG

ListanSolmu::ListanSolmu()
{
}
ListanSolmu::~ListanSolmu()
{
}
ListanSolmu::ListanSolmu(void *ptr)
{
	payload = ptr;
}
void ListanSolmu::set(void *ptr)
{
	payload = ptr;
}
void ListanSolmu::print()
{

}
Lista::Lista()
{
	//nollataan kaikki osoittimet
	start = 0;
	current = 0;
	end = 0;
	//nollataan solmujen määrä
	solmuja = 0;
#ifdef LISTDEBUG
	loki->writeToLog("Lista::Lista() : lista luotu");
#endif
}
Lista::~Lista()
{
}

//lisätään alkio listan loppuun
void Lista::add(void *dataptr)
{
	ListanSolmu *temp;
	solmuja++;

	if (start == 0) //lisätään listaan ensimmäistä alkiota
	{
		//luodaan uusi solmu
		temp = new ListanSolmu(dataptr);

		//koska solmu on ensimmäinen, nämä ovat molemmat 0
		temp->previous = 0;
		temp->next = 0;

		//molemmat "pääosoittimet" osoittamaan ekaan solmuun
		start = temp;
		end = temp;

#ifdef LISTDEBUG
		loki->writeToLog("Lista::add : Luotu ensimmäinen listan solmu");
		temp->print();
#endif
	}
	else
	{
		//luodaan uusi solmu listan perälle
		ListanSolmu *temp = new ListanSolmu(dataptr);
		//seuraavaa solmua ei tietenkään ole
		temp->next = 0; 

		//menee yhden askeleen lopun jälkeen. Muutetaan vanha listan loppu osoittamaan tähän solmuun
		temp->previous = end;
		end->next = temp;

		//uusi solmu on listan viimeinen
		end = temp;		
#ifdef LISTDEBUG
		loki->writeToLog("Lista::add : Luotu uusi solmu listaan");
		temp->print();
#endif
	}
}

//laitetaan uusi alkio työosoittimen kohdalle
bool Lista::insert(void *dataptr)
{
	if (current==0)
	{
		return false; //työosoitin ei ole kelvollinen, joten ei tehdä mitään ja palautetaan false
	}
	//ollaan listan lopussa
	if (current == end)
	{
		add(dataptr); //laitetaan listan loppuun uusi alkio
		return true;
	}
	//lisääminen onnistuu joka tapauksessa tästä eteenpäin, joten lisätään solmujen määrää
	solmuja++;
	//ollaan listan alussa tai keskellä, joten luodaan uusi solmu
	ListanSolmu *temp = new ListanSolmu(dataptr); 
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
bool Lista::remove()
{
	if (start == 0)	//lista tyhjä
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::remove : ei ole mitään poistettavaa");
#endif
		return false; //ei ole mitään poistettavaa
	}
	if (start == end)		//vain yksi alkio listassa (current == start)
	{
		solmuja--;
#ifdef LISTDEBUG
		loki->writeToLog("Lista::remove : vain yksi alkio listassa");
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
		loki->writeToLog("Lista::remove : poistetaan viimeinen alkio");
#endif
		removeLast();	//solmujen määrä muutetaan täällä
		return false;
	}
	if (current == start) //yritetään poistaa ensimmäistä alkiota
	{
		solmuja--;
#ifdef LISTDEBUG
		loki->writeToLog("Lista::remove : poistetaan ensimmäistä alkiota");
#endif
		ListanSolmu *temp = start->next;	//osoitetaan listan toiseen alkioon
		temp->previous = 0;					//josta tehdään listan ensimmäinen alkio
		if (start->payload != 0)
		{
			delete start->payload;
		}
		delete start; //poistetaan start-osoittimen osoittama alkio
		start = temp; //ja laitetaan se osoittamaan listan toiseen alkioon, joka on nyt ensimmäinen
		current = temp; //current myös

		return true;
	}
	//erikoistapaukset käsitelty

	solmuja--;
	ListanSolmu *temp;
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

//poistetaan listan viimeinen alkio

bool Lista::removeLast()
{
	if (start == 0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::removeLast : ei ole mitään poistettavaa");
#endif
		return false; //ei ole mitään poistettavaa
	}
	else
	{
		solmuja--;
		if (end->previous == 0) //jos listassa on vain yksi alkio
		{
#ifdef LISTDEBUG
			loki->writeToLog("Lista::removeLast : vain yksi alkio");
#endif
			if (end->payload != 0) //jos lista osoittaa johonkin
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
			loki->writeToLog("Lista::removeLast");
#endif
			//solmu, joka osoittaa edelliseen
			ListanSolmu *temp = end->previous;

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

//tuhotaan koko lista
void Lista::destroy()
{
	int temp = solmuja; //solmuja muuttuu removeLastissa, joten siksi tehdään siitä kopio nyt
#ifdef LISTDEBUG
	loki->writeToLog("Lista::destroy");
#endif
	for (int i=0;i<temp;i++)
		removeLast();
}

bool Lista::goToStart()
{
	if (start!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::goToStart() onnistui");
#endif
		current = start;	//lista on olemassa
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("Lista::goToStart() epäonnistui");
#endif
	current = 0;
	return false;
}
bool Lista::goToEnd()
{
	if (end!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::goToEnd() onnistui");
#endif
		current = end;	//lista on olemassa
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("Lista::goToStart() epäonnistui");
#endif
	current = 0;
	return false;
}
bool Lista::goForward()
{
	if (current == end)
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::goForward() yritti mennä lopusta ylitse!");
#endif
		return false;
	}
	if (current->next!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::goForward() onnistui");
#endif
		current = current->next;
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("Lista::goForward() epäonnistui");
#endif
	return false;
}
bool Lista::goBackwards()
{
	if (current->previous!=0)
	{
#ifdef LISTDEBUG
		loki->writeToLog("Lista::goBackwards() onnistui");
#endif
		current = current->previous;
		return true;
	}
#ifdef LISTDEBUG
	loki->writeToLog("Lista::goBackwards() epäonnistui");
#endif
	return false;
}

bool Lista::goToNode(int number)
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
int Lista::getCurrentNodeNumber()
{
	/* paskaa koodia! */
	int i=0;
	ListanSolmu *walker = start;
	while (walker != current)
	{
		i++;
		walker = walker->next;
	}
	return i;

}


void *Lista::getFirst()
{
	return start->payload;
}
void *Lista::getLast()
{
	return end->payload;
}
void *Lista::getCurrent()
{
	return current->payload;
}
void Lista::setCurrent(void *ptr)
{
	if (current->payload) //tuhotaan vanha
	{
		delete current->payload;
	}
	current->payload = ptr; 
}
int Lista::getNodeCount()
{
	return solmuja;
}

bool Lista::isAtEnd()
{
	if (current == end)
		return true;
	else return false;
}

bool Lista::isAtStart()
{
	if (current == start)
		return true;
	else return false;
}

void Lista::print()
{
#ifdef LISTDEBUG
	loki->writeToLog("Lista::print");
#endif
	ListanSolmu *walker = start;
	if (walker == 0)
		return; //listassa ei ole mitään
	while (walker!=0)
	{
		walker->print();
		walker = walker->next;
	}
}
 
