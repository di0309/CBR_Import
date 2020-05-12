using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;

namespace CBR_Import
{
    public class DbClass
    {
        private string connectionString;
        public DbClass()
        {
            connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        }
        public DbClass(string connectionString)
        {
            this.connectionString = connectionString;
        }
        public void ImportData(SqlXml document)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("ImportData", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(new SqlParameter("@doc", SqlDbType.Xml));
                cmd.Parameters["@doc"].Value = document;

                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                    Logger.WriteLog("Документ добавлен в базу");
                }
                catch (SqlException ex)
                {
                    Logger.WriteLog("Ошибка добавления в базу: " + ex.Message);
                }
            }
        }
    }
}
