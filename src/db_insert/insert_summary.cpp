#include <mariadb/conncpp.hpp>
#include <iostream>
#include "db_info.hpp"
const std::string path = "/home/arch_/Work/ProjectNotKnow/config/db_config.json";

void addSummary(std::shared_ptr<sql::PreparedStatement> &stmnt,
                sql::SQLString summary)
{
    try
    {
        stmnt->setString(1, summary);

        stmnt->executeUpdate();

        std::cout << "Successfully added the summary: " << summary << " to the database." << std::endl;
    }
    catch (sql::SQLException &e)
    {
        std::cerr << "Error adding summary to the database: "
                  << e.what() << std::endl;
    }
}

int main(int argc, char *argv[])
{
    json config;
    db_config(config, path);

    const std::string url = std::string{"jdbc:mariadb://127.0.0.1:3306/"} + std::string{config["database"]};

    for (int i = 1; i < argc; i++)
    {
        sql::SQLString summary(argv[i]);

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
                    "INSERT INTO entry.summaries(summary) VALUES (?)"));

            addSummary(stmnt, summary);

            conn->close();
        }
        catch (sql::SQLException &e)
        {
            std::cerr << "Error Connecting to the database: " << e.what() << std::endl;
            return 1;
        }
    }

    return 0;
}
