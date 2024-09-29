#include <mariadb/conncpp.hpp>
#include <iostream>
#include "db_info.hpp"
#include <sys/wait.h>
#include <cstdlib>
using std::cerr;
using std::cout;
using std::endl;
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

int getSummaryID(std::shared_ptr<sql::Statement> &stmnt, sql::SQLString summary)
{
    int ret = -1;
    std::string Query{std::string{"SELECT id FROM entry.summaries WHERE summary = "} + '\"' + static_cast<std::string>(summary) + '\"'};
    const char *DQuery = Query.c_str();

    try
    {
        std::unique_ptr<sql::ResultSet> res(
            stmnt->executeQuery(DQuery));

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
    if (argc <= 5)
    {
        cerr << "用法: " << argv[0] << " <文段> <作者> <出处> <页数> <摘要>..." << std::endl;
        return -1;
    }

    for (int i = 1; i < 4; i++)
    {
        if (strcmp(argv[1], "") == 0)
        {
            std::cerr << "用法: " << argv[0] << " <文段> <作者> <出处> <页数> " << "不能为空！" << std::endl;
            return -1;
        }
    }

    sql::SQLString passage(argv[1]);
    sql::SQLString author(argv[2]);
    sql::SQLString source(argv[3]);
    int page_number = std::stoi(argv[4]);

    // const std::string str = std::string{"insert_passage "} + '\"' + argv[1] + '\"' + ' ' + '\"' + argv[2] + '\"' + ' ' + '\"' + argv[3] + '\"' + ' ' + argv[4];
    // char *command = const_cast<char *>(str.c_str());
    // int res = system(command);
    // res = WEXITSTATUS(res);

    json config;
    db_config(config, path);

    const std::string url = std::string{"jdbc:mariadb://127.0.0.1:3306/"} + std::string{config["database"]};

    sql::Driver *driver = sql::mariadb::get_driver_instance();
    sql::SQLString URL(url);

    sql::Properties properties({{"user", static_cast<sql::SQLString>(config["username"])},
                                {"password", static_cast<sql::SQLString>(config["password"])},
                                {"useTls", "true"}});

    std::unique_ptr<sql::Connection> conn = nullptr;

    try
    {
        conn = std::unique_ptr<sql::Connection>{(driver->connect(URL, properties))};
        conn->setAutoCommit(false);
    }
    catch (sql::SQLException &e)
    {
        std::cerr << "Error Connecting to the database: " << e.what() << std::endl;
        return -1;
    }

    try
    {
        std::shared_ptr<sql::PreparedStatement> stmnt(
            conn->prepareStatement(
                "INSERT INTO entry.passages(passage, author, source, page_number) VALUES (?, ?, ?, ?)"));

        int res = addPassage(stmnt, passage, author, source, page_number);

        for (int i = 5; i < argc; i++)
        {
            sql::SQLString summary(argv[i]);

            std::shared_ptr<sql::PreparedStatement> stmnt(
                conn->prepareStatement(
                    "INSERT INTO entry.summaries(summary) VALUES (?)"));

            std::shared_ptr<sql::Statement> stmnt_summary(
                conn->createStatement());

            std::shared_ptr<sql::PreparedStatement> stmnt_medium(
                conn->prepareStatement(
                    "INSERT INTO entry.passage_summaries(passage_id,summary_id) VALUES (?, ?)"));

            int id_summary = getSummaryID(stmnt_summary, summary);

            int result = -1;

            if ((result = getSummaryID(stmnt_summary, summary)) != -1)
                ;
            else
                result = addSummary(stmnt, summary);

            addMedium(stmnt_medium, res, result);
        }

        conn->commit();
        cout << "Transaction Committed Success." << endl;
    }
    catch (sql::SQLException &e)
    {
        std::cerr << "Error Submit to the database: " << e.what() << std::endl;
        conn->rollback();
        std::cerr << "Fatal Error! Transaction rolled back" << std::endl;
        return -1;
    }

    conn->close();

    return 0;
}
