#include <mariadb/conncpp.hpp>
#include <iostream>
#include "db_info.hpp"
const std::string path = "/home/arch_/Work/ProjectNotKnow/config/db_config.json";

int addPassage(std::shared_ptr<sql::PreparedStatement> &stmnt,
			   sql::SQLString passage,
			   sql::SQLString author,
			   sql::SQLString source,
			   int32_t page_number)
{
	int last_id = -1;

	try
	{
		stmnt->setString(1, passage);
		stmnt->setString(2, author);
		stmnt->setString(3, source);
		stmnt->setInt(4, page_number);

		stmnt->executeUpdate();

		std::cout << "Successfully added the entry to the database." << std::endl;

		std::shared_ptr<sql::PreparedStatement> id_stmt(
			stmnt->getConnection()->prepareStatement("SELECT LAST_INSERT_ID()"));
		std::unique_ptr<sql::ResultSet> res(id_stmt->executeQuery());
		if (res->next())
		{
			last_id = res->getInt(1);
		}
	}
	catch (sql::SQLException &e)
	{
		std::cerr << "Error adding entry to the database: "
				  << e.what() << std::endl;
	}

	return last_id;
}

int main(int argc, char *argv[])
{
	if (argc != 5)
	{
		std::cerr << "用法: " << argv[0] << " <文段> <作者> <出处> <页数>" << std::endl;
		return -1;
	}

	json config;
	db_config(config, path);

	const std::string url = std::string{"jdbc:mariadb://127.0.0.1:3306/"} + std::string{config["database"]};

	sql::SQLString passage(argv[1]);
	sql::SQLString author(argv[2]);
	sql::SQLString source(argv[3]);
	int page_number = std::stoi(argv[4]);

	try
	{
		sql::Driver *driver = sql::mariadb::get_driver_instance();
		sql::SQLString URL(url);

		sql::Properties properties({{"user", static_cast<sql::SQLString>(config["username"])},
									{"password", static_cast<sql::SQLString>(config["password"])},
									{"useTls", "true"}});

		std::unique_ptr<sql::Connection> conn(driver->connect(URL, properties));

		std::shared_ptr<sql::PreparedStatement> stmnt(
			conn->prepareStatement(
				"INSERT INTO entry.passages(passage, author, source, page_number) VALUES (?, ?, ?, ?)"));

		int id = addPassage(stmnt, passage, author, source, page_number);

		conn->close();

		return id;
	}
	catch (sql::SQLException &e)
	{
		std::cerr << "Error Connecting to the database: " << e.what() << std::endl;
		return -1;
	}

	return 0;
}
