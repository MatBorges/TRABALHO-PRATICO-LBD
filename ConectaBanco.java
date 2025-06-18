package Layout;

import java.sql.Statement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

public class ConectaBanco {
	private String url, usuario, senha;
	private Connection con;
	
	public ConectaBanco(){
		url = "jdbc:postgresql://localhost:(porta do localhost)/(nome da database)";
		usuario = "postgres";
		senha = "postgres";
		try {	
			Class.forName("org.postgresql.Driver");
			con = DriverManager.getConnection(url, usuario, senha);	
			System.out.println("Conexão realizada com sucesso!");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public int executaSql(String sql){
		int res = 0;
		try{
			Statement s = con.createStatement();
			res = s.executeUpdate(sql);			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return res;
	}
       public ResultSet buscaDados(String sql){ 
		try{
			Statement s = con.createStatement();
			ResultSet rs = s.executeQuery(sql);
			return rs;
		}
		catch(Exception e){
			e.printStackTrace();
			return null;
		}
	}
       
       public void finalizaConexao(){
           try{
               con.close();
           }
           catch(Exception e){
               e.printStackTrace();
           }
       }
}