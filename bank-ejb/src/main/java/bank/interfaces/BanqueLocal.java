package bank.interfaces;
import jakarta.ejb.Local;
import bank.entities.Compte;
import bank.entities.Operation;
import java.util.List;
@Local
public interface BanqueLocal {
    void ajouterCompte(Compte c, Long codeClient);
    double consulterSolde(String codeCompte);
    void verser(String codeCompte, double montant);
    void retirer(String codeCompte, double montant);
    List<Operation> consulterOperations(String codeCompte);
}
