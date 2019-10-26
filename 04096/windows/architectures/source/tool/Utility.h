#ifndef Utility_h
#define Utility_h

#include <boost/filesystem.hpp>

#include <QString>


namespace fs = boost::filesystem;

namespace aurora {

inline fs::path toPath(const QString& path)
{
	#ifdef _WIN32
		return (const wchar_t*)path.utf16();
	#else
		return fs::path(path.toUtf8().data());	
	#endif
}

inline QString toQString(const std::string& str)
{
	return QString::fromUtf8(str.c_str());
}

} // namespace aurora

#endif
