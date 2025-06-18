/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package javaapplication4;
import java.sql.ResultSet;

/**
 *
 * @author kenzo
 */
public class TesteMain {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
         ConectaBanco banco = new ConectaBanco();

        
        String sqlInsert = "INSERT INTO test VALUES ('2', 'b')";
        int linhasAfetadas = banco.executaSql(sqlInsert);
        System.out.println("Linhas inseridas: " + linhasAfetadas);
        
        String sqlSelect = "SELECT * FROM test";
        try {
            ResultSet rs = banco.buscaDados(sqlSelect);
            while (rs.next()) {
                System.out.println("ID: " + rs.getInt("id") + 
                                   ", Nome: " + rs.getString("texto"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        banco.finalizaConexao();
    }
    
}
