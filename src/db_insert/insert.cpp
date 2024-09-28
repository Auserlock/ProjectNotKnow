#include <mariadb/conncpp.hpp>
#include <iostream>
#include "db_info.hpp"
#include <sys/wait.h>
#include <cstdlib>
using std::cerr;
using std::cout;
using std::endl;
const std::string path = "/home/arch_/Work/ProjectNotKnow/config/db_config.json";

int getSummaryID(std::shared_ptr<sql::Statement> &stmnt, sql::SQLString summary)
{
    int ret = -1;
    try
    {
        std::unique_ptr<sql::ResultSet> res(
            stmnt->executeQuery("SELECT id FROM entry.summaries WHERE summary = ?"));

        if (res->next())
        {
            ret = res->getInt("id");
        }
    }
    catch (sql::SQLException &e)
    {
        std::cerr << "Error printing contacts: "
                  << e.what() << std::endl;
    }

    return ret;
}

int addSummary(std::shared_ptr<sql::PreparedStatement> &stmnt,
               sql::SQLString summary)
{
    int last_id = -1;

    try
    {
        stmnt->setString(1, summary);

        stmnt->executeUpdate();

        std::cout << "Successfully added the summary: " << summary << " to the database." << std::endl;

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
        std::cerr << "Error adding summary to the database: "
                  << e.what() << std::endl;
    }
    return last_id;
}

void addMedium(std::shared_ptr<sql::PreparedStatement> &stmnt, int passage, int summary)
{
    try
    {
        stmnt->setInt(1, passage);
        stmnt->setInt(2, summary);

        stmnt->executeUpdate();

        std::cout << "Successfully added the medium table to the database." << std::endl;
    }
    catch (sql::SQLException &e)
    {
        std::cerr << "Error adding to the database: "
                  << e.what() << std::endl;
    }
}

int main(int argc, char *argv[])
{
    // if (argc <= 5)
    // {
    //     cerr << "用法: " << argv[0] << " <文段> <作者> <出处> <页数> <摘要>..." << std::endl;
    //     return -1;
    // }
    // const std::string str = std::string{"insert_passage "} + '\"' + argv[1] + '\"' + ' ' + '\"' + argv[2] + '\"' + ' ' + '\"' + argv[3] + '\"' + ' ' + argv[4];
    // char *command = const_cast<char *>(str.c_str());
    // int res = system(command);
    // res = WEXITSTATUS(res);

    json config;
    db_config(config, path);

    const std::string url = std::string{"jdbc:mariadb://127.0.0.1:3306/"} + std::string{config["database"]};

    for (int i = 5; i < argc; i++)
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

            // std::shared_ptr<sql::PreparedStatement> stmnt(
            //     conn->prepareStatement(
            //         "INSERT INTO entry.summaries(summary) VALUES (?)"));

            std::shared_ptr<sql::Statement> stmnt_summary(
                conn->createStatement());

            cout << getSummaryID(stmnt_summary, summary);
            // std::shared_ptr<sql::PreparedStatement> stmnt_medium(
            //     conn->prepareStatement(
            //         "INSERT INTO entry.passage_summaries(passage_id,summary_id) VALUES (?, ?)"));

            // int result = -1;
            // if ((result = getSummaryID(stmnt_summary, summary)) != -1)
            //     ;
            // else
            //     result = addSummary(stmnt, summary);

            // addMedium(stmnt_medium, res, result);

            conn->close();
        }
        catch (sql::SQLException &e)
        {
            std::cerr << "Error Connecting to the database: " << e.what() << std::endl;
            return -1;
        }
    }

    return 0;
}
