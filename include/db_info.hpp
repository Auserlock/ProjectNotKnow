#pragma once
#include <nlohmann/json.hpp>
using json = nlohmann::json;
extern json &db_config(json &, const std::string &);
