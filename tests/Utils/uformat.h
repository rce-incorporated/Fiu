#pragma once

#include <string>
#include <cstdio>
#include <utility>

template <typename... Args>
std::string uformat(const std::string& format, Args&&... args)
{
	constexpr size_t bufferSize = 256;
	char buffer[bufferSize];
	int result = snprintf(buffer, bufferSize, format.c_str(), std::forward<Args>(args)...);
	if (result < 0 || static_cast<size_t>(result) >= bufferSize)
	{
		return "Error: Formatting failed.";
	}
	return std::string(buffer);
}