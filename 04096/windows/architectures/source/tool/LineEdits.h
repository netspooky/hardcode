#ifndef LineEdits_h
#define LineEdits_h

#include <digi/Utility/lexicalCast.h>

#include <QtGui>


template <typename Type>
class NumericLineEdit : public QLineEdit
{
public:
	
	NumericLineEdit() {}

	void emitEditingFinished() {emit editingFinished();}

	void setValue(Type value)
	{
		this->setText(QString::fromUtf8(digi::lexicalCast<std::string>(value).c_str()));
	}
	
	Type value()
	{
		try
		{
			return digi::lexicalCast<Type>(this->text().toUtf8().data());
		}
		catch (std::exception&)
		{
		}
		return Type();
	}

	bool isValid()
	{
		try
		{
			digi::lexicalCast<Type>(this->text().toUtf8().data());
			return true;
		}
		catch (std::exception&)
		{
		}
		return false;
	}
};


#endif
