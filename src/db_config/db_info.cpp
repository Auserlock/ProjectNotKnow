#include <iostream>
#include <nlohmann/json.hpp>
#include "db_info.hpp"
#include <fstream>
using json = nlohmann::json;
const std::string config_file_path = "/root/config/db_config.json";

json& db_config(json &config)
{
	std::ifstream config_file {config_file_path};
	if(!config_file.is_open())
	{
		std::cerr << "Could not open the config file." << std::endl;
		std::cerr << "Program has ended with code 1." << std::endl;
		return config;
	}
	
	config_file >> config;

	config_file.close();
	return config;
}
