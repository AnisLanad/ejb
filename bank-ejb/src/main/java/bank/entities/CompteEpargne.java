package bank.entities;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import java.util.Date;
@Entity
@DiscriminatorValue("CE")
public class CompteEpargne extends Compte {
    private double taux;
    public CompteEpargne() {}
    public CompteEpargne(String codeCompte, Date dateCreation, double solde, double taux) {
        super(codeCompte, dateCreation, solde);
        this.taux = taux;
    }
    public double getTaux() { return taux; }
    public void setTaux(double taux) { this.taux = taux; }
}
